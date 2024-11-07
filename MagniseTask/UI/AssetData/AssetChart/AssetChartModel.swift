//
//  AssetChartModel.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation
import Combine
import SwiftUI

struct ChartDataItem: Identifiable {
    let id = UUID()
    let date: Date
    let price: Float
}

final class AssetChartModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let chartService = ChartDataService()
    
    @Published var chartItems: [ChartDataItem] = []
    
    var instrumentId: String? = nil {
        didSet {
            loadData()
        }
    }
    
    var minValue: Float {
        chartItems.map { $0.price }.min() ?? 0
    }
    
    var maxValue: Float {
        chartItems.map { $0.price }.max() ?? 0
    }
    
    func loadData() {
        guard let instrumentId = instrumentId else { return }
        
        chartService.getChartData(instrumentId: instrumentId, interval: 1, periodicity: "day", count: 10)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Get chart data failed: \(error)")
                }
            }, receiveValue: { [weak self] items in
                self?.chartItems = items.map { .init(date: DateFormatter.isoDateFormatterTimeZone.date(from: $0.t) ?? Date(), price: $0.c) }
            })
            .store(in: &cancellables)
    }
}

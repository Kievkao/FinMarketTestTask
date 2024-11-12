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

protocol AssetChartModelProtocol: ObservableObject {
    var chartItems: [ChartDataItem] { get set }
    var minValue: Float { get }
    var maxValue: Float { get }
    
    func loadData(for instrumentId: String)
}

final class AssetChartModel: AssetChartModelProtocol {
    private var cancellables = Set<AnyCancellable>()
    private let chartService: ChartDataServiceProtocol
    
    @Published var chartItems: [ChartDataItem] = []
    
    var minValue: Float {
        chartItems.map { $0.price }.min() ?? 0
    }
    
    var maxValue: Float {
        chartItems.map { $0.price }.max() ?? 0
    }
    
    init(chartService: ChartDataServiceProtocol) {
        self.chartService = chartService
    }
    
    func loadData(for instrumentId: String) {
        chartService.getChartData(instrumentId: instrumentId, interval: 1, periodicity: "day", count: 10)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Get chart data failed: \(error)")
                    // TODO: Pass errors outside
                }
            }, receiveValue: { [weak self] items in
                self?.chartItems = items.map { .init(date: DateFormatter.isoDateFormatterTimeZone.date(from: $0.t) ?? Date(), price: $0.c) }
            })
            .store(in: &cancellables)
    }
}

final class MockAssetChartModel: AssetChartModelProtocol {
    var chartItems: [ChartDataItem] = []
    var instrumentId: String? = "1"
    var minValue: Float = 0
    var maxValue: Float = 7
    
    func loadData(for instrumentId: String) {}
}

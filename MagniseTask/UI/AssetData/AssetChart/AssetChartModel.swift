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

enum ChartDataError: Error {
    case dataLoading(String)
}

extension ChartDataError: LocalizedError {
    var failureReason: String? {
        switch self {
        case .dataLoading:
            "Loading error"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case let .dataLoading(description):
            return description
        }
    }}

protocol AssetChartModelProtocol: ObservableObject {
    var chartItems: [ChartDataItem] { get set }
    var minValue: Float { get }
    var maxValue: Float { get }
    
    var errorPublisher: Published<ChartDataError?>.Publisher { get }
    
    func loadData(for instrumentId: String)
}

final class AssetChartModel: AssetChartModelProtocol {
    private var cancellables = Set<AnyCancellable>()
    private let chartService: ChartDataServiceProtocol
    
    @Published var chartItems: [ChartDataItem] = []
    
    @Published var apiError: ChartDataError?
    var errorPublisher: Published<ChartDataError?>.Publisher { $apiError }
    
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
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.apiError = .dataLoading(error.localizedDescription)
                }
            }, receiveValue: { [weak self] items in
                self?.apiError = nil
                self?.chartItems = items.map { .init(date: DateFormatter.isoDateFormatterTimeZone.date(from: $0.t) ?? Date(), price: $0.c) }
            })
            .store(in: &cancellables)
    }
}

final class MockAssetChartModel: AssetChartModelProtocol {
    var chartItems: [ChartDataItem] = []
    var instrumentId: String? = "1"
    @Published var apiError: ChartDataError?
    var errorPublisher: Published<ChartDataError?>.Publisher { $apiError }
    var minValue: Float = 0
    var maxValue: Float = 7
    
    func loadData(for instrumentId: String) {}
}

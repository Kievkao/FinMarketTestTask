//
//  ChartDataService.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 09.11.2024.
//

import Foundation
import Combine

protocol ChartDataServiceProtocol {
    func getChartData(instrumentId: String, interval: Int, periodicity: String, count: Int) -> AnyPublisher<[HistoricalDataItem], Error>
}

final class ChartDataService: ChartDataServiceProtocol {
    let apiClient = URLSessionAPIClient<Endpoint>()
    
    func getChartData(instrumentId: String, interval: Int, periodicity: String, count: Int) -> AnyPublisher<[HistoricalDataItem], Error> {
        apiClient.request(.getHistoricalData(instrumentId: instrumentId, interval: interval, periodicity: periodicity, count: count))
            .map { (response: HistoricalDataResponse) in
                response.data
            }
            .eraseToAnyPublisher()
    }
}

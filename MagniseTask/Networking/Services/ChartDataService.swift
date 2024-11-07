//
//  ChartDataService.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 09.11.2024.
//

import Foundation
import Combine

final class ChartDataService {
    let apiClient = URLSessionAPIClient<Endpoint>()
    
    func getChartData(instrumentId: String, interval: Int, periodicity: String, count: Int) -> AnyPublisher<[HistoricalDataItem], Error> {
        apiClient.request(.getHistoricalData(instrumentId: instrumentId, provider: "oanda", interval: interval, periodicity: periodicity, count: count))
            .map { (response: HistoricalDataResponse) in
                response.data
            }
            .eraseToAnyPublisher()
    }
}

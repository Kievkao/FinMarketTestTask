//
//  InstrumentsService.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation
import Combine

protocol InstrumentsServiceProtocol {
    func getInstruments() -> AnyPublisher<[Instrument], Error>
}

final class InstrumentsService: InstrumentsServiceProtocol {
    let apiClient = URLSessionAPIClient<Endpoint>()
    
    func getInstruments() -> AnyPublisher<[Instrument], Error> {
        apiClient.request(.getInstruments(provider: "oanda", kind: "forex"))
            .map { (response: InstrumentsResponse) in
                response.data
            }
            .eraseToAnyPublisher()
    }
}

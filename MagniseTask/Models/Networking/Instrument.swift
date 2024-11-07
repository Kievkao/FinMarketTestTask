//
//  Instrument.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation

struct InstrumentsResponse: Decodable {
    let data: [Instrument]
}

struct Instrument: Codable, Equatable {
    let id: String
    let symbol: String
    let currency: String
    let baseCurrency: String
}

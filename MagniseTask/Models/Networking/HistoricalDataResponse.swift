//
//  HistoricalDataResponse.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 07.11.2024.
//

import Foundation

struct HistoricalDataItem: Decodable {
    let t: String
    let c: Float
}

struct HistoricalDataResponse: Decodable {
    let data: [HistoricalDataItem]
}

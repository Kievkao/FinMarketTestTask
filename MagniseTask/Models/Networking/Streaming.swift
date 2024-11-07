//
//  Streaming.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 04.11.2024.
//

import Foundation

struct StreamingRequest: Encodable {
    let type = "l1-subscription"
    let id = "1"
    let instrumentId: String
    let provider = "oanda"
    let subscribe = true
    let kinds = ["last"]
    
    init(instrumentId: String) {
        self.instrumentId = instrumentId
    }
}

struct StreamingResponse: Decodable {
    let type: String
    let sessionId: String
}

struct SubscriptionResponse: Decodable {
    let type: String
    let requestId: String
}

struct SubscriptionStatusResponse: Decodable {
    let type: String
    let name: String
    let codeName: String
    let status: String
}

final class ExchangeOperation: Decodable {
    let timestamp: String
    let price: Float
}

struct ExchangeResponse: Decodable {
    let last: ExchangeOperation
}

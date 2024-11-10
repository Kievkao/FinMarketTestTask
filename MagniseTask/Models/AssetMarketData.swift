//
//  AssetMarketData.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 09.11.2024.
//

import Foundation

struct AssetMarketData: Equatable {    
    let symbol: String
    var priceString: String
    let price: Float
    let time: String
    let date: Date
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 5
        return formatter
    }()
    
    init(from operation: ExchangeOperation, symbol: String, currencySign: String) {
        Self.numberFormatter.currencySymbol = currencySign
        
        let price = operation.price
        let priceString = Self.numberFormatter.string(from: NSNumber(value: operation.price)) ?? "\(currencySign)\(operation.price)"
        
        let date: Date
        let time: String
        
        if let parsedDate = DateFormatter.isoDateFormatterFractSeconds.date(from: operation.timestamp) {
            date = parsedDate
            time = DateFormatter.outputDateFormatter.string(from: date)
        } else {
            date = .now
            time = operation.timestamp
        }

        self.init(symbol: symbol, priceString: priceString, price: price, time: time, date: date)
    }
    
    init(symbol: String, priceString: String, price: Float, time: String, date: Date) {
        self.symbol = symbol
        self.priceString = priceString
        self.price = price
        self.time = time
        self.date = date
    }
}

extension AssetMarketData {
    static func mock() -> AssetMarketData {
        return .init(symbol: "USD", priceString: "$12", price: 12, time: "Aug 7, 2:34 AM", date: .now)
    }
}

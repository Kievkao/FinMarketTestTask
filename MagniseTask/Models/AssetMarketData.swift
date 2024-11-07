//
//  AssetMarketData.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 09.11.2024.
//

import Foundation

struct AssetMarketData {    
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
        self.symbol = symbol
        Self.numberFormatter.currencySymbol = currencySign
        self.price = operation.price
        self.priceString = Self.numberFormatter.string(from: NSNumber(value: operation.price)) ?? "\(currencySign)\(operation.price)"
        
        if let date = DateFormatter.isoDateFormatterFractSeconds.date(from: operation.timestamp) {
            self.date = date
            self.time = DateFormatter.outputDateFormatter.string(from: date)
        } else {
            self.date = .now
            self.time = operation.timestamp
        }
    }
}

//
//  Formatters.swift
//  MagniseTask
//
//  Created by Andrii Kravchenko on 09.11.2024.
//

import Foundation

extension DateFormatter {
    static let isoDateFormatterFractSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    static let isoDateFormatterTimeZone: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        return formatter
    }()
    
    static let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
}

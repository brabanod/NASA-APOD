//
//  DateUtils.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 26.11.22.
//

import Foundation

struct DateUtils {
    
    /// - Returns: A `Date` object representing today, without the time component.
    static func today() -> Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date()))
    }
    
    /// - Parameters:
    ///     - days: Amout of days to add or subtract
    ///
    /// - Returns: A `Date` object representing today adding the amount of days, without the time component.
    static func today(adding days: Int) -> Date? {
        guard let today = today() else { return nil }
        return Calendar.current.date(byAdding: .day, value: days, to: today)
    }
}

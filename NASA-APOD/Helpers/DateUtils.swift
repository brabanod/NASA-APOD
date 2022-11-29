//
//  DateUtils.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 26.11.22.
//

import Foundation

struct DateUtils {
    
    /// Creates a standardized representation of a date by stripping away the time component.
    ///
    /// - Parameters:
    ///     - date: The date to be modified.
    ///
    /// - Returns: The given date without the time component.
    static func strip(_ date: Date) -> Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date))
    }
    
    /// - Parameters:
    ///     - date: The date to be modified.
    ///     - days: The amount of days to add (or subtract with negative sign)
    ///
    /// - Returns: A `Date` object representing the given date and adding the amount of days, without the time component.
    static func date(_ date: Date, adding days: Int) -> Date? {
        guard let initialDate = Self.strip(date) else { return nil }
        return Calendar.current.date(byAdding: .day, value: days, to: initialDate)
    }
    
    /// - Returns: A `Date` object representing today, without the time component.
    static func today() -> Date? {
        return Self.strip(Date())
    }
    
    /// - Parameters:
    ///     - days: The amount of days to add (or subtract with negative sign)
    ///
    /// - Returns: A `Date` object representing today adding the amount of days, without the time component.
    static func today(adding days: Int) -> Date? {
        guard let today = today() else { return nil }
        return Self.date(today, adding: days)
    }
}

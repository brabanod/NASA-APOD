//
//  DateUtilsTests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 29.11.22.
//

import XCTest
@testable import NASA_APOD

final class DateUtilsTests: XCTestCase {
    
    // date = 2022-12-29 13:14:20
    let date = Date(timeIntervalSince1970: 1672319660)
    
    let parseStrategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", timeZone: TimeZone.current)
    
    func testStrip() throws {
        let dateStripped = DateUtils.strip(date)
        XCTAssertNotEqual(date, dateStripped)
        
        // Parse a date from string without time
        let dateString = "2022-12-29"
        let dateParsed = try Date(dateString, strategy: parseStrategy)
        
        XCTAssertEqual(dateStripped, dateParsed)
    }

    func testDateAddingDays() throws {
        let datePlus5 = DateUtils.date(date, adding: 5)
        let dateMinus5 = DateUtils.date(date, adding: -5)
        
        let datePlus5String = "2023-01-03"
        let datePlus5Parsed = try Date(datePlus5String, strategy: parseStrategy)
        let dateMinus5String = "2022-12-24"
        let dateMinus5Parsed = try Date(dateMinus5String, strategy: parseStrategy)
        
        XCTAssertEqual(datePlus5, datePlus5Parsed)
        XCTAssertEqual(dateMinus5, dateMinus5Parsed)
    }
    
    func testToday() {
        // In rare cases this test might fail, if the first line is executed on another day than the assert statements
        let today = DateUtils.today()
        
        // The only thing that today is expected to do is to strip the current date. Since strip is already tested use it to test this.
        XCTAssertEqual(today, DateUtils.strip(Date()))
    }
    
    func testTodayAddingDays() {
        // In rare cases this test might fail, if the first two lines are executed on another day than the assert statements
        let todayPlus5 = DateUtils.today(adding: 5)
        let todayMinus5 = DateUtils.today(adding: -5)
        
        XCTAssertEqual(todayPlus5, DateUtils.date(Date(), adding: 5))
        XCTAssertEqual(todayMinus5, DateUtils.date(Date(), adding: -5))
    }
}

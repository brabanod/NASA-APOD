//
//  APODCellViewTests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 10.12.22.
//

import XCTest
@testable import NASA_APOD

final class APODCellViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Disable animations
        UIView.setAnimationsEnabled(false)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testSetTitle() {
        let testView = APODCellView(frame: .zero)
        XCTAssertNil(testView.title)
        
        testView.setTitle("Demo Title")
        XCTAssertEqual(testView.title, "Demo Title")
    }
    
    @MainActor func testSetAccessoryText() {
        let testView = APODCellView(frame: .zero)
        XCTAssertNil(testView.accessoryText)
        
        testView.setAccessoryText("Demo Accessory Text")
        XCTAssertEqual(testView.accessoryText, "Demo Accessory Text")
    }
    
    @MainActor func testSetImage() {
        let testView = APODCellView(frame: .zero)
        XCTAssertNil(testView.image)
        
        testView.setImage(APODDemoData.sampleImage)
        XCTAssertNotNil(testView.image)
    }

}

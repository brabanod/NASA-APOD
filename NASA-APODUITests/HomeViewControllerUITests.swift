//
//  HomeViewControllerUITests.swift
//  NASA-APODUITests
//
//  Created by Braband, Pascal on 10.12.22.
//

import XCTest

final class HomeViewControllerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Start app
        app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        // Call launch in test methods, to be able to pass test specific launch arguments.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Test that highlight view is displayed.
    func testHighlightView() throws {
        app.launch()
        let highlightView = app.collectionViews["APODList"].otherElements["Highlight"]
        
        XCTAssertTrue(highlightView.otherElements["Image"].exists)
        XCTAssertEqual(highlightView.staticTexts["Title"].label, "Artemis 1 Moonshot")
        XCTAssertEqual(highlightView.staticTexts["Accessory"].label, "\(String(localized: "Today")) | © John Kraus")
    }
    
    /// Test that list is displayed.
    func testList() {
        app.launch()
        let apodList = app.collectionViews["APODList"]
                
        // Check that two initial cells exist. They should be presented in the view
        XCTAssertTrue(apodList.cells["Cell0"].exists)
        XCTAssertTrue(apodList.cells["Cell1"].exists)
        
        while (!apodList.cells["Cell2"].exists) {
            apodList.swipeUp()
        }
        XCTAssertTrue(apodList.cells["Cell2"].exists)
        XCTAssertTrue(apodList.cells["Cell3"].exists)
        
        while (!apodList.cells["Cell4"].exists) {
            apodList.swipeUp()
        }
        XCTAssertTrue(apodList.cells["Cell4"].exists)
        XCTAssertTrue(apodList.cells["Cell5"].exists)
        
        while (!apodList.cells["Cell6"].exists) {
            apodList.swipeUp()
        }
        XCTAssertTrue(apodList.cells["Cell6"].exists)
        XCTAssertTrue(apodList.cells["Cell7"].exists)
        
        while (!apodList.cells["Cell8"].exists) {
            apodList.swipeUp()
        }
        XCTAssertTrue(apodList.cells["Cell8"].exists)
        XCTAssertTrue(apodList.cells["Cell9"].exists)
        
        while (!apodList.cells["Cell10"].exists) {
            apodList.swipeUp()
        }
        XCTAssertTrue(apodList.cells["Cell10"].exists)
        XCTAssertTrue(apodList.cells["Cell11"].exists)
    }
    
    /// Test that cell content is displayed correctly.
    func testCell() {
        app.launch()
        
        let cell = app.collectionViews["APODList"].cells["Cell0"]
        XCTAssertTrue(cell.otherElements["Image"].exists)
        XCTAssertEqual(cell.staticTexts["Title"].label, "Airglow Ripples over Tibet")
        XCTAssertEqual(cell.staticTexts["Accessory"].label, "11/28/2022")
    }
    
    /// Test that alert is displayed when connection fails.
    func testAlert() {
        app.launchArguments.append("-FailRequests")
        app.launch()
        
        let alert = app.alerts.firstMatch
        
        XCTAssertTrue(alert.waitForExistence(timeout: 1))
        XCTAssertEqual(alert.label, String(localized: "Stars are not aligned", table: "Error"))
        XCTAssertTrue(alert.staticTexts[String(localized: "Could not load the Astronomy Picture of the day from NASA.", table: "Error")].exists)
        XCTAssertTrue(alert.buttons["AlertOkAction"].exists)
    }
}

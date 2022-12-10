//
//  DetailViewControllerUITests.swift
//  NASA-APODUITests
//
//  Created by Braband, Pascal on 09.12.22.
//

import XCTest

final class DetailViewControllerUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Start app
        app = XCUIApplication()
        app.launchArguments = ["-UITests"]
        app.launch()

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Check that detail view can be opened from cell.
    func testOpenDetailFromCell() throws {
        // Open first cell
        app.collectionViews["APODList"].cells["Cell0"].tap()
        let detail = app.otherElements["DetailView"]
        
        // Check content
        XCTAssertTrue(detail.otherElements["Image"].exists)
        
        XCTAssertEqual(detail.staticTexts["Title"].label, String(localized: "Title", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Source"].label, String(localized: "Source", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Date"].label, String(localized: "Date", table: "Detail"))
        XCTAssertFalse(detail.staticTexts["Video"].exists)
        
        XCTAssertEqual(detail.staticTexts["TitleValue"].label, "Airglow Ripples over Tibet")
        XCTAssertEqual(detail.staticTexts["CopyrightValue"].label, "Jeff Dai")
        XCTAssertEqual(detail.staticTexts["DateValue"].label, "11/20/2022")
        XCTAssertFalse(detail.buttons["Watch"].exists)
        XCTAssertTrue(detail.staticTexts["Explanation"].label.starts(with: "Why would the sky look like a giant target? Airglow."))
        
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Check that app returned to home page again
        XCTAssertTrue(app.collectionViews["APODList"].exists)
    }

    /// Check that detail view can be opened from highlight view.
    func testOpenDetailFromHighlight() throws {
        // Open highlight detail
        app.collectionViews.otherElements["Highlight"].tap()
        let detail = app.otherElements["DetailView"]
        
        // Check content
        XCTAssertTrue(detail.otherElements["Image"].exists)
        
        XCTAssertEqual(detail.staticTexts["Title"].label, String(localized: "Title", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Source"].label, String(localized: "Source", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Date"].label, String(localized: "Date", table: "Detail"))
        XCTAssertFalse(detail.staticTexts["Video"].exists)
        
        XCTAssertEqual(detail.staticTexts["TitleValue"].label, "Artemis 1 Moonshot")
        XCTAssertEqual(detail.staticTexts["CopyrightValue"].label, "John Kraus")
        XCTAssertEqual(detail.staticTexts["DateValue"].label, "11/19/2022")
        XCTAssertFalse(detail.buttons["Watch"].exists)
        XCTAssertTrue(detail.staticTexts["Explanation"].label.starts(with: "When the Artemis 1 mission's Orion spacecraft makes its"))
        
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Check that app returned to home page again
        XCTAssertTrue(app.collectionViews["APODList"].exists)
    }
    
    /// Test that public domain notice is displayed, when no copyright/source is given.
    func testPublicDomain() throws {
        // Open first cell
        app.collectionViews["APODList"].cells["Cell3"].tap()
        let detail = app.otherElements["DetailView"]
        
        // Check content
        XCTAssertTrue(detail.otherElements["Image"].exists)
        
        XCTAssertEqual(detail.staticTexts["Title"].label, String(localized: "Title", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Source"].label, String(localized: "Source", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Date"].label, String(localized: "Date", table: "Detail"))
        XCTAssertFalse(detail.staticTexts["Video"].exists)
        
        XCTAssertEqual(detail.staticTexts["TitleValue"].label, "Earthset from Orion")
        XCTAssertEqual(detail.staticTexts["CopyrightValue"].label, String(localized: "Public Domain"))
        XCTAssertEqual(detail.staticTexts["DateValue"].label, "11/23/2022")
        XCTAssertFalse(detail.buttons["Watch"].exists)
        XCTAssertTrue(detail.staticTexts["Explanation"].label.starts(with: "Eight billion people are about to disappear in this snapshot from space."))
        
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Check that app returned to home page again
        XCTAssertTrue(app.collectionViews["APODList"].exists)
    }
    
    /// Test that displaying video attributes work.
    func testVideo() throws {
        // Open first cell
        app.collectionViews["APODList"].cells["Cell1"].tap()
        let detail = app.otherElements["DetailView"]
        
        // Check content
        XCTAssertTrue(detail.otherElements["Image"].exists)
        
        XCTAssertEqual(detail.staticTexts["Title"].label, String(localized: "Title", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Source"].label, String(localized: "Source", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Date"].label, String(localized: "Date", table: "Detail"))
        XCTAssertEqual(detail.staticTexts["Video"].label, String(localized: "Video", table: "Detail"))
        
        XCTAssertEqual(detail.staticTexts["TitleValue"].label, "The Butterfly Nebula from Hubble")
        XCTAssertEqual(detail.staticTexts["CopyrightValue"].label, String(localized: "Public Domain"))
        XCTAssertEqual(detail.staticTexts["DateValue"].label, "11/21/2022")
        XCTAssertTrue(detail.buttons["Watch"].exists)
        XCTAssertTrue(detail.staticTexts["Explanation"].label.starts(with: "Stars can make beautiful patterns as they age"))
        
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Check that app returned to home page again
        XCTAssertTrue(app.collectionViews["APODList"].exists)
    }
    
    /// Test that video attributes are shown and hidden, when switching between image APOD and video APOD (image first).
    func testImageAndVideoDetailAlternating() {
        let apodList = app.collectionViews["APODList"]
        let detail = app.otherElements["DetailView"]
        
        // Open image
        apodList.cells["Cell0"].tap()
        XCTAssertFalse(detail.staticTexts["Video"].exists)
        XCTAssertFalse(detail.buttons["Watch"].exists)
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Open video
        apodList.cells["Cell1"].tap()
        XCTAssertEqual(detail.staticTexts["Video"].label, String(localized: "Video", table: "Detail"))
        XCTAssertTrue(detail.buttons["Watch"].exists)
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Open image
        apodList.cells["Cell0"].tap()
        XCTAssertFalse(detail.staticTexts["Video"].exists)
        XCTAssertFalse(detail.buttons["Watch"].exists)
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
    
    /// Test that video attributes are shown and hidden, when switching between image APOD and video APOD (video first).
    func testVideoAndImageDetailAlternating() {
        let apodList = app.collectionViews["APODList"]
        let detail = app.otherElements["DetailView"]
        
        // Open video
        apodList.cells["Cell1"].tap()
        XCTAssertEqual(detail.staticTexts["Video"].label, String(localized: "Video", table: "Detail"))
        XCTAssertTrue(detail.buttons["Watch"].exists)
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Open image
        apodList.cells["Cell0"].tap()
        XCTAssertFalse(detail.staticTexts["Video"].exists)
        XCTAssertFalse(detail.buttons["Watch"].exists)
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Open video
        apodList.cells["Cell1"].tap()
        XCTAssertEqual(detail.staticTexts["Video"].label, String(localized: "Video", table: "Detail"))
        XCTAssertTrue(detail.buttons["Watch"].exists)
        detail/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
}

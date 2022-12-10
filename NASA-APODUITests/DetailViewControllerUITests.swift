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
    
    /// Test that detail view can be opened from cell.
    func testOpenDetailFromCell() throws {
        // Open first cell
        app.collectionViews["APODList"].cells["Cell0"].tap()
        
        // Check content
        XCTAssertTrue(app.otherElements["Image"].exists)
        
        XCTAssertEqual(app.staticTexts["Title"].label, String(localized: "Title", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Source"].label, String(localized: "Source", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Date"].label, String(localized: "Date", table: "Detail"))
        XCTAssertFalse(app.staticTexts["Video"].exists)
        
        XCTAssertEqual(app.staticTexts["TitleValue"].label, "Airglow Ripples over Tibet")
        XCTAssertEqual(app.staticTexts["CopyrightValue"].label, "Jeff Dai")
        XCTAssertEqual(app.staticTexts["DateValue"].label, "11/20/2022")
        XCTAssertFalse(app.buttons["Watch"].exists)
        XCTAssertTrue(app.staticTexts["Explanation"].label.starts(with: "Why would the sky look like a giant target? Airglow."))
        
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Check that app returned to home page again
        XCTAssertTrue(app.collectionViews["APODList"].exists)
    }

    /// Test that detail view can be opened from highlight view.
    func testOpenDetailFromHighlight() throws {
        // Open highlight detail
        app.collectionViews.otherElements["Highlight"].tap()
        
        // Check content
        XCTAssertTrue(app.otherElements["Image"].exists)
        
        XCTAssertEqual(app.staticTexts["Title"].label, String(localized: "Title", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Source"].label, String(localized: "Source", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Date"].label, String(localized: "Date", table: "Detail"))
        XCTAssertFalse(app.staticTexts["Video"].exists)
        
        XCTAssertEqual(app.staticTexts["TitleValue"].label, "Artemis 1 Moonshot")
        XCTAssertEqual(app.staticTexts["CopyrightValue"].label, "John Kraus")
        XCTAssertEqual(app.staticTexts["DateValue"].label, "11/19/2022")
        XCTAssertFalse(app.buttons["Watch"].exists)
        XCTAssertTrue(app.staticTexts["Explanation"].label.starts(with: "When the Artemis 1 mission's Orion spacecraft makes its"))
        
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Check that app returned to home page again
        XCTAssertTrue(app.collectionViews["APODList"].exists)
    }
    
    /// Test that public domain notice is displayed, when no copyright/source is given.
    func testPublicDomain() throws {
        // Open first cell
        app.collectionViews["APODList"].cells["Cell3"].tap()
        
        // Check content
        XCTAssertTrue(app.otherElements["Image"].exists)
        
        XCTAssertEqual(app.staticTexts["Title"].label, String(localized: "Title", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Source"].label, String(localized: "Source", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Date"].label, String(localized: "Date", table: "Detail"))
        XCTAssertFalse(app.staticTexts["Video"].exists)
        
        XCTAssertEqual(app.staticTexts["TitleValue"].label, "Earthset from Orion")
        XCTAssertEqual(app.staticTexts["CopyrightValue"].label, String(localized: "Public Domain"))
        XCTAssertEqual(app.staticTexts["DateValue"].label, "11/23/2022")
        XCTAssertFalse(app.buttons["Watch"].exists)
        XCTAssertTrue(app.staticTexts["Explanation"].label.starts(with: "Eight billion people are about to disappear in this snapshot from space."))
        
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Check that app returned to home page again
        XCTAssertTrue(app.collectionViews["APODList"].exists)
    }
    
    /// Test that displaying video attributes work.
    func testVideo() throws {
        // Open first cell
        app.collectionViews["APODList"].cells["Cell1"].tap()
        
        // Check content
        XCTAssertTrue(app.otherElements["Image"].exists)
        
        XCTAssertEqual(app.staticTexts["Title"].label, String(localized: "Title", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Source"].label, String(localized: "Source", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Date"].label, String(localized: "Date", table: "Detail"))
        XCTAssertEqual(app.staticTexts["Video"].label, String(localized: "Video", table: "Detail"))
        
        XCTAssertEqual(app.staticTexts["TitleValue"].label, "The Butterfly Nebula from Hubble")
        XCTAssertEqual(app.staticTexts["CopyrightValue"].label, String(localized: "Public Domain"))
        XCTAssertEqual(app.staticTexts["DateValue"].label, "11/21/2022")
        XCTAssertTrue(app.buttons["Watch"].exists)
        XCTAssertTrue(app.staticTexts["Explanation"].label.starts(with: "Stars can make beautiful patterns as they age"))
        
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Check that app returned to home page again
        XCTAssertTrue(app.collectionViews["APODList"].exists)
    }
    
    /// Test that video attributes are shown and hidden, when switching between image APOD and video APOD (image first).
    func testImageAndVideoDetailAlternating() {
        let apodList = app.collectionViews["APODList"]
        
        // Open image
        apodList.cells["Cell0"].tap()
        XCTAssertFalse(app.staticTexts["Video"].exists)
        XCTAssertFalse(app.buttons["Watch"].exists)
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Open video
        apodList.cells["Cell1"].tap()
        XCTAssertEqual(app.staticTexts["Video"].label, String(localized: "Video", table: "Detail"))
        XCTAssertTrue(app.buttons["Watch"].exists)
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Open image
        apodList.cells["Cell0"].tap()
        XCTAssertFalse(app.staticTexts["Video"].exists)
        XCTAssertFalse(app.buttons["Watch"].exists)
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
    
    /// Test that video attributes are shown and hidden, when switching between image APOD and video APOD (video first).
    func testVideoAndImageDetailAlternating() {
        let apodList = app.collectionViews["APODList"]
        
        // Open video
        apodList.cells["Cell1"].tap()
        XCTAssertEqual(app.staticTexts["Video"].label, String(localized: "Video", table: "Detail"))
        XCTAssertTrue(app.buttons["Watch"].exists)
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Open image
        apodList.cells["Cell0"].tap()
        XCTAssertFalse(app.staticTexts["Video"].exists)
        XCTAssertFalse(app.buttons["Watch"].exists)
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Open video
        apodList.cells["Cell1"].tap()
        XCTAssertEqual(app.staticTexts["Video"].label, String(localized: "Video", table: "Detail"))
        XCTAssertTrue(app.buttons["Watch"].exists)
        app/*@START_MENU_TOKEN@*/.buttons["Dismiss"]/*[[".buttons[\"Schließen\"]",".buttons[\"Dismiss\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
}

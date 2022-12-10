//
//  LoadableImageViewTests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 10.12.22.
//

import XCTest
@testable import NASA_APOD

final class LoadableImageViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Disable animations
        UIView.setAnimationsEnabled(false)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testShowHideLoadingViewAnimated() {
        let testView = LoadableImageView(frame: .zero)
        XCTAssertFalse(testView.loadingView.isHidden)
        
        testView.hideLoadingView(animated: true)
        let expectLoadingViewHidden = expectation(for: NSPredicate(block: { _, _ in
            testView.loadingView.isHidden == true
        }), evaluatedWith: testView.loadingView)
        wait(for: [expectLoadingViewHidden], timeout: 2)
        XCTAssertTrue(testView.loadingView.isHidden)
        
        testView.showLoadingView(animated: true)
        let expectLoadingViewShown = expectation(for: NSPredicate(block: { _, _ in
            testView.loadingView.isHidden == false
        }), evaluatedWith: testView.loadingView)
        wait(for: [expectLoadingViewShown], timeout: 2)
        XCTAssertFalse(testView.loadingView.isHidden)
    }
    
    func testShowHideLoadingViewNotAnimated() {
        let testView = LoadableImageView(frame: .zero)
        XCTAssertFalse(testView.loadingView.isHidden)
        
        testView.hideLoadingView(animated: false)
        let expectLoadingViewHidden = expectation(for: NSPredicate(block: { _, _ in
            testView.loadingView.isHidden == true
        }), evaluatedWith: testView.loadingView)
        wait(for: [expectLoadingViewHidden], timeout: 2)
        XCTAssertTrue(testView.loadingView.isHidden)
        
        testView.showLoadingView(animated: false)
        let expectLoadingViewShown = expectation(for: NSPredicate(block: { _, _ in
            testView.loadingView.isHidden == false
        }), evaluatedWith: testView.loadingView)
        wait(for: [expectLoadingViewShown], timeout: 2)
        XCTAssertFalse(testView.loadingView.isHidden)
    }

    func testSetImageHidesLoadingView() {
        let testView = LoadableImageView(frame: .zero)
        
        XCTAssertNil(testView.image)
        XCTAssertNil(testView.imageView.image)
        XCTAssertFalse(testView.loadingView.isHidden)
        
        testView.image = APODDemoData.sampleImage
        
        // Test that loading view is hidden
        XCTAssertNotNil(testView.image)
        XCTAssertNotNil(testView.imageView.image)
        let expectLoadingViewHidden = expectation(for: NSPredicate(block: { _, _ in
            testView.loadingView.isHidden == true
        }), evaluatedWith: testView.loadingView)
        wait(for: [expectLoadingViewHidden], timeout: 2)
        XCTAssertTrue(testView.loadingView.isHidden)
    }
}

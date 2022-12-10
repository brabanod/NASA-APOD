//
//  APODHighlightViewTests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 10.12.22.
//

import XCTest
@testable import NASA_APOD

final class APODHighlightViewTests: XCTestCase {
    
    var cache: APODCache!

    override func setUpWithError() throws {
        // Disable animations
        UIView.setAnimationsEnabled(false)
        
        // Setup APODCache
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [APODAPIMockDefault.self]
        let urlSession = URLSession(configuration: configuration)
        let apodAPI = try APODAPI(urlSession: urlSession)
        APODAPIMockDefault.simulateDelay = false
        cache = try APODCache(api: apodAPI)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testLoadAPOD() async throws {
        let testView = APODHighlightView(frame: .zero, cache: cache)
        
        // Await loading APOD here, so that APODHighlightView does not have to wait.
        let apod = try await cache.apod(for: Date())
        
        XCTAssertEqual(testView.apod, apod)
    }

}

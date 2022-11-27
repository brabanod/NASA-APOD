//
//  APODCacheTests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 26.11.22.
//

import XCTest
@testable import NASA_APOD

final class APODCacheTests: XCTestCase {

    var apodAPI: APODAPI!
    var apiKey: String!
    let apiBaseURL = "https://api.nasa.gov/planetary/apod"
    
    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [APODAPIMockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        apodAPI = try APODAPI(urlSession: urlSession)
        apiKey = (Bundle.main.object(forInfoDictionaryKey: "NASAAPIKey") as! String)
    }
    
    
    // MARK: Initial load
    
    /// Test initially loading (only metadata and thumbnails).
    func testInitialLoadOnlyMeta() async throws {
        var requestCount = 0
        APODAPIMockURLProtocol.requestHandler = APODAPIMockRequestHandler.successCount(
            data: { _ in
                guard let date = DateUtils.today(adding: -requestCount) else { fatalError("Could not create date.") }
                return APODDemoData.singleAPODJSON(with: date).data(using: .utf8)
            }, expectedURL: { count in
                guard let date = DateUtils.today(adding: -requestCount) else { fatalError("Could not create date.") }
                return "\(self.apiBaseURL)?api_key=\(self.apiKey!)&date=\(date.ISO8601Format(.iso8601Date(timeZone: TimeZone.current)))"
            },count: {
                requestCount += 1
                return requestCount
            })
        
        // Initially load APODs
        let cache = try await APODCache(api: apodAPI)
        
        let requestCountAfterInitialLoad = requestCount
        
        for days in (1...cache.initialLoadAmount) {
            // Get date, fail promise if date could not be retrieved
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            try await cache.apod(for: date) { apod in
                XCTAssertEqual(apod.date, date)
                XCTAssertEqual(apod.thumbnail, nil)
                XCTAssertEqual(apod.image, nil)
            }
        }
        
        // Check that request count did not change i. e. all APODs were loaded from cache
        XCTAssertEqual(requestCountAfterInitialLoad, requestCount)
    }
    
    /// Test initially loading (only metadata and thumbnails).
    func testInitialLoadMetaAndThumbnail() async throws {
        
    }
    
    /// Test initially loading (only metadata and images).
    func testInitialLoadMetaAndImage() async throws {
        
    }
    
    /// Test initially loading (metadata, thumbnails and images).
    func testInitialLoadAll() async throws {
        
    }
    
    
    // MARK: Access uncached APOD
    
    /// Test loading an uncached APOD (only metadata).
    func testAccessAPODUncachedOnlyMeta() async throws {
        
    }
    
    /// Test loading an uncached APOD (metadata and thumbnail).
    func testAccessAPODUncachedMetaAndThumbnail() async throws {
        
    }
    
    /// Test loading an uncached APOD (metadata and image).
    func testAccessAPODUncachedMetaAndImage() async throws {
        
    }
    
    /// Test loading an uncached APOD (metadata, thumbnail and image).
    func testAccessAPODUncachedAll() async throws {
        
    }
    
    
    // MARK: Access cached APOD
    
    /// Test loading a cached APOD (only metadata).
    func testAccessAPODCachedOnlyMeta() async throws {
        
    }
    
    /// Test loading a cached APOD (metadata and thumbnail).
    func testAccessAPODCachedMetaAndThumbnail() async throws {
        
    }
    
    /// Test loading a cached APOD (metadata and image).
    func testAccessAPODCachedMetaAndImage() async throws {
        
    }
    
    /// Test loading a cached APOD (metadata, thumbnail and image).
    func testAccessAPODCachedAll() async throws {
        
    }
    
    
    // MARK: Access during Initial load
    
    /// Test accessing an APOD while the initial load is running (only metadata).
    func testAccessOnInitialLoadMeta() async throws {
        
    }
    
    /// Test accessing an APOD while the initial load is running (metadata and thumbnail).
    func testAccessOnInitialLoadMetaAndThumbnail() async throws {
        
    }
    
    /// Test accessing an APOD while the initial load is running (metadata and image).
    func testAccessOnInitialLoadMetaAndImage() async throws {
        
    }
    
    /// Test accessing an APOD while the initial load is running (metadata, thumbnail and image).
    func testAccessOnInitialLoadAll() async throws {
        
    }
    
    
    // MARK: Access same simultaneously
    
    /// Test accessing the same APOD simultaneously, so that another Task is still running (only metadata).
    func testAccessSameMeta() async throws {
        
    }
    
    /// Test accessing the same APOD simultaneously, so that another Task is still running (metadata and thumbnail).
    func testAccessSameMetaAndThumbnail() async throws {
        
    }
    
    /// Test accessing the same APOD simultaneously, so that another Task is still running (metadata and image).
    func testAccessSameMetaAndImage() async throws {
        
    }
    
    /// Test accessing the same APOD simultaneously, so that another Task is still running (metadata, thumbnail and image).
    func testAccessSameAll() async throws {
        
    }
    
    
    // MARK: Access different simultaneously
    
    /// Test accessing a different APOD simultaneously, so that another Task is still running (only metadata).
    func testAccessDifferentMeta() async throws {
        
    }
    
    /// Test accessing a different APOD simultaneously, so that another Task is still running (metadata and thumbnail).
    func testAccessDifferentMetaAndThumbnail() async throws {
        
    }
    
    /// Test accessing a different APOD simultaneously, so that another Task is still running (metadata and image).
    func testAccessDifferentMetaAndImage() async throws {
        
    }
    
    /// Test accessing a different APOD simultaneously, so that another Task is still running (metadata, thumbnail and image).
    func testAccessDifferentAll() async throws {
        
    }
}

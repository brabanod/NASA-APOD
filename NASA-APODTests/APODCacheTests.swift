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
        APODAPIMockURLProtocol.requestHandler = sequenceMock()
        
        // Initially load APODs
        let cache = try await APODCache(api: apodAPI)
        
        XCTAssertEqual(requestCount, cache.initialLoadAmount)
        XCTAssertEqual(requestCountMeta, cache.initialLoadAmount)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 0)
        let requestCountAfterInitialLoad = requestCount
        let requestCountMetaAfterInitialLoad = requestCountMeta
        let requestCountThumbnailAfterInitialLoad = requestCountThumbnail
        let requestCountImageAfterInitialLoad = requestCountImage
        
        // Check that all initially loaded APODs are present
        for days in (1...cache.initialLoadAmount) {
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            try await MainActor.run {
                try cache.apod(for: date) { apod in
                    XCTAssertEqual(apod.date, date)
                    XCTAssertEqual(apod.thumbnail, nil)
                    XCTAssertEqual(apod.image, nil)
                }
            }
        }
        
        // Check that request count did not change i. e. all APODs were loaded from cache
        XCTAssertEqual(requestCountAfterInitialLoad, requestCount)
        XCTAssertEqual(requestCountMetaAfterInitialLoad, requestCountMeta)
        XCTAssertEqual(requestCountThumbnailAfterInitialLoad, requestCountThumbnail)
        XCTAssertEqual(requestCountImageAfterInitialLoad, requestCountImage)
    }
    
    /// Test initially loading (only metadata and thumbnails).
    func testInitialLoadMetaAndThumbnail() async throws {
        APODAPIMockURLProtocol.requestHandler = sequenceMock()
        
        // Initially load APODs
        let cache = try await APODCache(api: apodAPI, withThumbnails: true)
        
        XCTAssertEqual(requestCount, cache.initialLoadAmount * 2)
        XCTAssertEqual(requestCountMeta, cache.initialLoadAmount)
        XCTAssertEqual(requestCountThumbnail, cache.initialLoadAmount)
        XCTAssertEqual(requestCountImage, 0)
        let requestCountAfterInitialLoad = requestCount
        let requestCountMetaAfterInitialLoad = requestCountMeta
        let requestCountThumbnailAfterInitialLoad = requestCountThumbnail
        let requestCountImageAfterInitialLoad = requestCountImage
        
        // Check that all initially loaded APODs are present
        for days in (1...cache.initialLoadAmount) {
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            try await MainActor.run {
                try cache.apod(for: date) { apod in
                    guard let apodThumbnailData = apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
                    XCTAssertEqual(apod.date, date)
                    XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
                    XCTAssertEqual(apod.image, nil)
                }
            }
        }
        
        // Check that request count did not change i. e. all APODs were loaded from cache
        XCTAssertEqual(requestCountAfterInitialLoad, requestCount)
        XCTAssertEqual(requestCountMetaAfterInitialLoad, requestCountMeta)
        XCTAssertEqual(requestCountThumbnailAfterInitialLoad, requestCountThumbnail)
        XCTAssertEqual(requestCountImageAfterInitialLoad, requestCountImage)
    }
    
    /// Test initially loading (only metadata and images).
    func testInitialLoadMetaAndImage() async throws {
        APODAPIMockURLProtocol.requestHandler = sequenceMock()
        
        // Initially load APODs
        let cache = try await APODCache(api: apodAPI, withImages: true)
        
        XCTAssertEqual(requestCount, cache.initialLoadAmount * 2)
        XCTAssertEqual(requestCountMeta, cache.initialLoadAmount)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, cache.initialLoadAmount)
        let requestCountAfterInitialLoad = requestCount
        let requestCountMetaAfterInitialLoad = requestCountMeta
        let requestCountThumbnailAfterInitialLoad = requestCountThumbnail
        let requestCountImageAfterInitialLoad = requestCountImage
        
        // Check that all initially loaded APODs are present
        for days in (1...cache.initialLoadAmount) {
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            try await MainActor.run {
                try cache.apod(for: date) { apod in
                    guard let apodImageData = apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
                    XCTAssertEqual(apod.date, date)
                    XCTAssertEqual(apod.thumbnail, nil)
                    XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
                }
            }
        }
        
        // Check that request count did not change i. e. all APODs were loaded from cache
        XCTAssertEqual(requestCountAfterInitialLoad, requestCount)
        XCTAssertEqual(requestCountMetaAfterInitialLoad, requestCountMeta)
        XCTAssertEqual(requestCountThumbnailAfterInitialLoad, requestCountThumbnail)
        XCTAssertEqual(requestCountImageAfterInitialLoad, requestCountImage)
    }
    
    /// Test initially loading (metadata, thumbnails and images).
    func testInitialLoadAll() async throws {
        APODAPIMockURLProtocol.requestHandler = sequenceMock()
        
        // Initially load APODs
        let cache = try await APODCache(api: apodAPI, withThumbnails: true, withImages: true)
        
        XCTAssertEqual(requestCount, cache.initialLoadAmount * 3)
        XCTAssertEqual(requestCountMeta, cache.initialLoadAmount)
        XCTAssertEqual(requestCountThumbnail, cache.initialLoadAmount)
        XCTAssertEqual(requestCountImage, cache.initialLoadAmount)
        let requestCountAfterInitialLoad = requestCount
        let requestCountMetaAfterInitialLoad = requestCountMeta
        let requestCountThumbnailAfterInitialLoad = requestCountThumbnail
        let requestCountImageAfterInitialLoad = requestCountImage
        
        // Check that all initially loaded APODs are present
        for days in (1...cache.initialLoadAmount) {
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            try await MainActor.run {
                try cache.apod(for: date) { apod in
                    guard let apodThumbnailData = apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
                    guard let apodImageData = apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
                    XCTAssertEqual(apod.date, date)
                    XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
                    XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
                }
            }
        }
        
        // Check that request count did not change i. e. all APODs were loaded from cache
        XCTAssertEqual(requestCountAfterInitialLoad, requestCount)
        XCTAssertEqual(requestCountMetaAfterInitialLoad, requestCountMeta)
        XCTAssertEqual(requestCountThumbnailAfterInitialLoad, requestCountThumbnail)
        XCTAssertEqual(requestCountImageAfterInitialLoad, requestCountImage)
    }
    
    
    // MARK: Access uncached APOD
    
    /// Test loading an uncached APOD (only metadata).
    func testAccessAPODUncachedOnlyMeta() async throws {
        // Test uncached first, then cached (this eliminates the cached tests
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
    
    
    // MARK: - Helpers
    
    /// Request count for all queries.
    var requestCount: Int = 0
    
    /// Request count for metadata query.
    var requestCountMeta: Int = 0
    
    /// Request count for thumbnail query.
    var requestCountThumbnail: Int = 0
    
    /// Request count for image query.
    var requestCountImage: Int = 0
    
    func sequenceMock() -> ((URLRequest) throws -> (HTTPURLResponse, Data?)) {
        requestCount = 0
        requestCountMeta = 0
        requestCountThumbnail = 0
        requestCountImage = 0
        
        return APODAPIMockRequestHandler.successCount(
            data: { url in
                if url == APODDemoData.singleAPODThumbnailURL {
                    // Request thumbnail
                    return APODDemoData.sampleImageData
                } else if url == APODDemoData.singleAPODImageURL {
                    // Request image
                    return APODDemoData.sampleImage2Data
                } else {
                    // Request metadata
                    guard let date = DateUtils.today(adding: -self.requestCountMeta) else { fatalError("Could not create date.") }
                    return APODDemoData.singleAPODJSON(with: date).data(using: .utf8)
                }
            }, expectedURL: { url in
                if url == APODDemoData.singleAPODThumbnailURL {
                    // Request thumbnail
                    return APODDemoData.singleAPODThumbnailURL
                } else if url == APODDemoData.singleAPODImageURL {
                    // Request image
                    return APODDemoData.singleAPODImageURL
                } else {
                    // Request metadata
                    guard let date = DateUtils.today(adding: -self.requestCountMeta) else { fatalError("Could not create date.") }
                    return "\(self.apiBaseURL)?api_key=\(self.apiKey!)&date=\(date.ISO8601Format(.iso8601Date(timeZone: TimeZone.current)))"
                }
            }, count: { url in
                // Increase overall request count.
                self.requestCount += 1
                
                // Increase specific request counts
                if url == APODDemoData.singleAPODThumbnailURL {
                    // Request thumbnail
                    self.requestCountThumbnail += 1
                } else if url == APODDemoData.singleAPODImageURL {
                    // Request image
                    self.requestCountImage += 1
                } else {
                    // Request metadata
                    self.requestCountMeta += 1
                }
            })
    }
}

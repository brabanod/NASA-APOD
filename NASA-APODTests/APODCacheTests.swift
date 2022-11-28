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
    
    let initialLoadAmount: Int = 10
    
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
        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: initialLoadAmount, withThumbnails: false, withImages: false)
        
        XCTAssertEqual(requestCount, initialLoadAmount)
        XCTAssertEqual(requestCountMeta, initialLoadAmount)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 0)
        let requestCountAfterInitialLoad = requestCount
        let requestCountMetaAfterInitialLoad = requestCountMeta
        let requestCountThumbnailAfterInitialLoad = requestCountThumbnail
        let requestCountImageAfterInitialLoad = requestCountImage
        
        // Check that all initially loaded APODs are present
        for days in (1...initialLoadAmount) {
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            let apod = try await cache.apod(for: date)
            await AsyncAssertEqual(await apod.date, date)
            await AsyncAssertEqual(await apod.thumbnail, nil)
            await AsyncAssertEqual(await apod.image, nil)
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
        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: initialLoadAmount, withThumbnails: true, withImages: false)
        
        XCTAssertEqual(requestCount, initialLoadAmount * 2)
        XCTAssertEqual(requestCountMeta, initialLoadAmount)
        XCTAssertEqual(requestCountThumbnail, initialLoadAmount)
        XCTAssertEqual(requestCountImage, 0)
        let requestCountAfterInitialLoad = requestCount
        let requestCountMetaAfterInitialLoad = requestCountMeta
        let requestCountThumbnailAfterInitialLoad = requestCountThumbnail
        let requestCountImageAfterInitialLoad = requestCountImage
        
        // Check that all initially loaded APODs are present
        for days in (1...initialLoadAmount) {
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            let apod = try await  cache.apod(for: date)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            await AsyncAssertEqual(await apod.date, date)
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            await AsyncAssertEqual(await apod.image, nil)
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
        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: initialLoadAmount, withThumbnails: false, withImages: true)
        
        XCTAssertEqual(requestCount, initialLoadAmount * 2)
        XCTAssertEqual(requestCountMeta, initialLoadAmount)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, initialLoadAmount)
        let requestCountAfterInitialLoad = requestCount
        let requestCountMetaAfterInitialLoad = requestCountMeta
        let requestCountThumbnailAfterInitialLoad = requestCountThumbnail
        let requestCountImageAfterInitialLoad = requestCountImage
        
        // Check that all initially loaded APODs are present
        for days in (1...initialLoadAmount) {
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            let apod = try await cache.apod(for: date)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            await AsyncAssertEqual(await apod.date, date)
            await AsyncAssertEqual(await apod.thumbnail, nil)
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
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
        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: initialLoadAmount, withThumbnails: true, withImages: true)
        
        XCTAssertEqual(requestCount, initialLoadAmount * 3)
        XCTAssertEqual(requestCountMeta, initialLoadAmount)
        XCTAssertEqual(requestCountThumbnail, initialLoadAmount)
        XCTAssertEqual(requestCountImage, initialLoadAmount)
        let requestCountAfterInitialLoad = requestCount
        let requestCountMetaAfterInitialLoad = requestCountMeta
        let requestCountThumbnailAfterInitialLoad = requestCountThumbnail
        let requestCountImageAfterInitialLoad = requestCountImage
        
        // Check that all initially loaded APODs are present
        for days in (1...initialLoadAmount) {
            guard let date = DateUtils.today(adding: -days) else { fatalError("Could not create date.") }
            
            let apod = try await cache.apod(for: date)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            await AsyncAssertEqual(await apod.date, date)
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
        }
        
        // Check that request count did not change i. e. all APODs were loaded from cache
        XCTAssertEqual(requestCountAfterInitialLoad, requestCount)
        XCTAssertEqual(requestCountMetaAfterInitialLoad, requestCountMeta)
        XCTAssertEqual(requestCountThumbnailAfterInitialLoad, requestCountThumbnail)
        XCTAssertEqual(requestCountImageAfterInitialLoad, requestCountImage)
    }
    
    
    // MARK: Access APOD
    
    /// Test loading an uncached APOD (only metadata) first, then call the same one cached.
    func testAccessAPODOnlyMeta() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }
        
        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()
        
        let cache = try APODCache(api: apodAPI)
        
        // Test uncached
        let apodUncached = try await cache.apod(for: testDate, withThumbnail: false, withImage: false)
        
        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 0)
        await AsyncAssertEqual(await apodUncached.date, testDate)
        await AsyncAssertEqual(await apodUncached.thumbnail, nil)
        await AsyncAssertEqual(await apodUncached.image, nil)
        
        // Test cached
        let apodCached = try await cache.apod(for: testDate, withThumbnail: false, withImage: false)
        
        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 0)
        await AsyncAssertEqual(await apodCached.date, testDate)
        await AsyncAssertEqual(await apodCached.thumbnail, nil)
        await AsyncAssertEqual(await apodCached.image, nil)
    }
    
    /// Test loading an uncached APOD (metadata and thumbnail).
    func testAccessAPODMetaAndThumbnail() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)

        // Test uncached
        let apodUncached = try await cache.apod(for: testDate, withThumbnail: true, withImage: false)

        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 0)
        guard let apodUncachedThumbnailData = await apodUncached.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apodUncached.date, testDate)
        XCTAssertEqual(apodUncachedThumbnailData, APODDemoData.sampleImageData)
        await AsyncAssertEqual(await apodUncached.image, nil)

        // Test cached
        let apodCached = try await cache.apod(for: testDate, withThumbnail: true, withImage: false)

        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 0)
        guard let apodCachedThumbnailData = await apodCached.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apodCached.date, testDate)
        XCTAssertEqual(apodCachedThumbnailData, APODDemoData.sampleImageData)
        await AsyncAssertEqual(await apodCached.image, nil)
    }
    
    /// Test loading an uncached APOD (metadata and image).
    func testAccessAPODMetaAndImage() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)

        // Test uncached
        let apodUncached = try await cache.apod(for: testDate, withThumbnail: false, withImage: true)

        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 1)
        guard let apodUncachedImageData = await apodUncached.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apodUncached.date, testDate)
        await AsyncAssertEqual(await apodUncached.thumbnail, nil)
        XCTAssertEqual(apodUncachedImageData, APODDemoData.sampleImage2Data)

        // Test cached
        let apodCached = try await cache.apod(for: testDate, withThumbnail: false, withImage: true)

        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 1)
        guard let apodCachedImageData = await apodCached.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apodCached.date, testDate)
        await AsyncAssertEqual(await apodUncached.thumbnail, nil)
        XCTAssertEqual(apodCachedImageData, APODDemoData.sampleImage2Data)
    }
    
    /// Test loading an uncached APOD (metadata, thumbnail and image).
    func testAccessAPODAll() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)

        // Test uncached
        let apodUncached = try await cache.apod(for: testDate, withThumbnail: true, withImage: true)

        XCTAssertEqual(requestCount, 3)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 1)
        guard let apodUncachedThumbnailData = await apodUncached.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        guard let apodUncachedImageData = await apodUncached.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apodUncached.date, testDate)
        XCTAssertEqual(apodUncachedThumbnailData, APODDemoData.sampleImageData)
        XCTAssertEqual(apodUncachedImageData, APODDemoData.sampleImage2Data)

        // Test cached
        let apodCached = try await cache.apod(for: testDate, withThumbnail: true, withImage: true)

        XCTAssertEqual(requestCount, 3)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 1)
        guard let apodCachedThumbnailData = await apodCached.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        guard let apodCachedImageData = await apodCached.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apodCached.date, testDate)
        XCTAssertEqual(apodCachedThumbnailData, APODDemoData.sampleImageData)
        XCTAssertEqual(apodCachedImageData, APODDemoData.sampleImage2Data)
    }
    
    
    // MARK: Access during Initial load
    
    /// Test accessing an APOD while the initial load is running (only metadata).
    func testAccessOnInitialLoadMeta() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: 1, withThumbnails: false, withImages: false)
        
        // Test access APOD from initial load
        let apod = try await cache.apod(for: testDate, withThumbnail: false, withImage: false)

        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 0)
        await AsyncAssertEqual(await apod.date, testDate)
        await AsyncAssertEqual(await apod.thumbnail, nil)
        await AsyncAssertEqual(await apod.image, nil)
    }
    
    /// Test accessing an APOD while the initial load is running (metadata and thumbnail).
    func testAccessOnInitialLoadMetaAndThumbnail() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: 1, withThumbnails: true, withImages: false)
        
        // Test access APOD from initial load
        let apod = try await cache.apod(for: testDate, withThumbnail: true, withImage: false)

        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 0)
        guard let apodCachedThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        XCTAssertEqual(apodCachedThumbnailData, APODDemoData.sampleImageData)
        await AsyncAssertEqual(await apod.image, nil)
    }
    
    /// Test accessing an APOD while the initial load is running (metadata and image).
    func testAccessOnInitialLoadMetaAndImage() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: 1, withThumbnails: false, withImages: true)
        
        // Test access APOD from initial load
        let apod = try await cache.apod(for: testDate, withThumbnail: false, withImage: true)

        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 1)
        guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        await AsyncAssertEqual(await apod.thumbnail, nil)
        XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
    }
    
    /// Test accessing an APOD while the initial load is running (metadata, thumbnail and image).
    func testAccessOnInitialLoadAll() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: 1, withThumbnails: true, withImages: true)
        
        // Test access APOD from initial load
        let apod = try await cache.apod(for: testDate, withThumbnail: true, withImage: true)

        XCTAssertEqual(requestCount, 3)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 1)
        guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
        XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
    }
    
    
    // MARK: Access same simultaneously
    
    /// Test accessing the same unchached APOD simultaneously, so that the load Task is still running (only metadata).
    func testAccessUncachedSameMeta() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        
        let expectFirstAPOD = expectation(description: "Load APOD from API")
        let expectSecondAPOD = expectation(description: "Load APOD from cache")
        
        // Load APOD by request
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectFirstAPOD.fulfill()
        }
        
        // Load same APOD should wait for the first load task to finish and then use cached APOD
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectSecondAPOD.fulfill()
        }
        
        await waitForExpectations(timeout: 1.0)
        
        // Access again, this time directly from cache, no other request running
        let apod = try await cache.apod(for: testDate)
        await AsyncAssertEqual(await apod.date, testDate)
        
        // Both requests were started simultaneously, however still only one request to the API should be made. The other access needs to wait for this to finish and then use the cache.
        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 0)
    }
    
    /// Test accessing the same unchached APOD simultaneously, so that another Task is still running (metadata and thumbnail).
    func testAccessSameUncachedMetaAndThumbnail() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        
        let expectFirstAPOD = expectation(description: "Load APOD from API")
        let expectSecondAPOD = expectation(description: "Load APOD from cache")
        let expectFirstAPODThumbnail = expectation(description: "Load APOD thumbnail from API")
        let expectSecondAPODThumbnail = expectation(description: "Load APOD thumbnail from cache")
        
        // Load APOD by request
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectFirstAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withThumbnail: true)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            expectFirstAPODThumbnail.fulfill()
        }
        
        // Load same APOD should wait for the first load task to finish and then use cached APOD
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectSecondAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withThumbnail: true)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            expectSecondAPODThumbnail.fulfill()
        }
        
        await waitForExpectations(timeout: 1.0)
        
        // Access again, this time directly from cache, no other request running
        let apod = try await cache.apod(for: testDate, withThumbnail: true)
        guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
        
        // Both requests were started simultaneously, however still only one request to the API should be made. The other access needs to wait for this to finish and then use the cache.
        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 0)
    }
    
    /// Test accessing the same unchached APOD simultaneously, so that another Task is still running (metadata and image).
    func testAccessSameUncachedMetaAndImage() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        
        let expectFirstAPOD = expectation(description: "Load APOD from API")
        let expectSecondAPOD = expectation(description: "Load APOD from cache")
        let expectFirstAPODImage = expectation(description: "Load APOD image from API")
        let expectSecondAPODImage = expectation(description: "Load APOD image from cache")
        
        // Load APOD by request
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectFirstAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withImage: true)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
            expectFirstAPODImage.fulfill()
        }
        
        // Load same APOD should wait for the first load task to finish and then use cached APOD
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectSecondAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withImage: true)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
            expectSecondAPODImage.fulfill()
        }
        
        await waitForExpectations(timeout: 1.0)
        
        // Access again, this time directly from cache, no other request running
        let apod = try await cache.apod(for: testDate, withImage: true)
        guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
        
        // Both requests were started simultaneously, however still only one request to the API should be made. The other access needs to wait for this to finish and then use the cache.
        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 1)
    }
    
    /// Test accessing the same uncached APOD simultaneously, so that another Task is still running (metadata, thumbnail and image).
    func testAccessUncachedSameAll() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        
        let expectFirstAPOD = expectation(description: "Load APOD from API")
        let expectSecondAPOD = expectation(description: "Load APOD from cache")
        let expectFirstAPODThumbnail = expectation(description: "Load APOD thumbnail from API")
        let expectSecondAPODThumbnail = expectation(description: "Load APOD thumbnail from cache")
        let expectFirstAPODImage = expectation(description: "Load APOD image from API")
        let expectSecondAPODImage = expectation(description: "Load APOD image from cache")
        
        /// Load APOD by request
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectFirstAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withThumbnail: true)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            expectFirstAPODThumbnail.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withImage: true)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
            expectFirstAPODImage.fulfill()
        }
        
        // Load same APOD should wait for the first load task to finish and then use cached APOD
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectSecondAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withThumbnail: true)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            expectSecondAPODThumbnail.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withImage: true)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
            expectSecondAPODImage.fulfill()
        }
        
        await waitForExpectations(timeout: 1.0)
        
        // Access again, this time directly from cache, no other request running
        let apod = try await cache.apod(for: testDate, withThumbnail: true, withImage: true)
        guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
        XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
        
        // Both requests were started simultaneously, however still only one request to the API should be made. The other access needs to wait for this to finish and then use the cache.
        XCTAssertEqual(requestCount, 3)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 1)
    }
    
    
    // MARK: Access different simultaneously
    
    /// Test accessing a different APOD simultaneously, so that another Task is still running (only metadata).
    func testAccessDifferentMeta() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }
        guard let testDate2 = DateUtils.today(adding: -2) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        
        let expectFirstAPOD = expectation(description: "Load APOD from API")
        let expectSecondAPOD = expectation(description: "Load APOD from cache")
        
        // Load APOD by request
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectFirstAPOD.fulfill()
        }
        
        // Load different APOD should wait for the first load task to finish and then use cached APOD
        Task {
            let apod = try await cache.apod(for: testDate2)
            await AsyncAssertEqual(await apod.date, testDate2)
            expectSecondAPOD.fulfill()
        }
        
        await waitForExpectations(timeout: 1.0)
        
        // Access again, this time directly from cache, no other request running
        let apod = try await cache.apod(for: testDate)
        await AsyncAssertEqual(await apod.date, testDate)
        
        let apod2 = try await cache.apod(for: testDate2)
        await AsyncAssertEqual(await apod2.date, testDate2)
        
        // Both requests were started simultaneously, however still only one request to the API should be made. The other access needs to wait for this to finish and then use the cache.
        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 2)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 0)
    }
    
    /// Test accessing a different APOD simultaneously, so that another Task is still running (metadata and thumbnail).
    func testAccessDifferentMetaAndThumbnail() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }
        guard let testDate2 = DateUtils.today(adding: -2) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        
        let expectFirstAPOD = expectation(description: "Load APOD from API")
        let expectSecondAPOD = expectation(description: "Load APOD from cache")
        let expectFirstAPODThumbnail = expectation(description: "Load APOD thumbnail from API")
        let expectSecondAPODThumbnail = expectation(description: "Load APOD thumbnail from cache")
        
        // Load APOD by request
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectFirstAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withThumbnail: true)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            expectFirstAPODThumbnail.fulfill()
        }
        
        // Load different APOD should wait for the first load task to finish and then use cached APOD
        Task {
            let apod = try await cache.apod(for: testDate2)
            await AsyncAssertEqual(await apod.date, testDate2)
            expectSecondAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate2, withThumbnail: true)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            expectSecondAPODThumbnail.fulfill()
        }
        
        await waitForExpectations(timeout: 1.0)
        
        // Access again, this time directly from cache, no other request running
        let apod = try await cache.apod(for: testDate, withThumbnail: true)
        guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
        
        let apod2 = try await cache.apod(for: testDate2, withThumbnail: true)
        guard let apod2ThumbnailData = await apod2.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod2.date, testDate2)
        XCTAssertEqual(apod2ThumbnailData, APODDemoData.sampleImageData)
        
        // Both requests were started simultaneously, however still only one request to the API should be made. The other access needs to wait for this to finish and then use the cache.
        XCTAssertEqual(requestCount, 4)
        XCTAssertEqual(requestCountMeta, 2)
        XCTAssertEqual(requestCountThumbnail, 2)
        XCTAssertEqual(requestCountImage, 0)
    }
    
    /// Test accessing a different APOD simultaneously, so that another Task is still running (metadata and image).
    func testAccessDifferentMetaAndImage() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }
        guard let testDate2 = DateUtils.today(adding: -2) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        
        let expectFirstAPOD = expectation(description: "Load APOD from API")
        let expectSecondAPOD = expectation(description: "Load APOD from cache")
        let expectFirstAPODImage = expectation(description: "Load APOD image from API")
        let expectSecondAPODImage = expectation(description: "Load APOD image from cache")
        
        // Load APOD by request
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectFirstAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withImage: true)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
            expectFirstAPODImage.fulfill()
        }
        
        // Load different APOD should wait for the first load task to finish and then use cached APOD
        Task {
            let apod = try await cache.apod(for: testDate2)
            await AsyncAssertEqual(await apod.date, testDate2)
            expectSecondAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate2, withImage: true)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
            expectSecondAPODImage.fulfill()
        }
        
        await waitForExpectations(timeout: 1.0)
        
        // Access again, this time directly from cache, no other request running
        let apod = try await cache.apod(for: testDate, withImage: true)
        guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
        
        let apod2 = try await cache.apod(for: testDate2, withImage: true)
        guard let apod2ImageData = await apod2.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod2.date, testDate2)
        XCTAssertEqual(apod2ImageData, APODDemoData.sampleImage2Data)
        
        // Both requests were started simultaneously, however still only one request to the API should be made. The other access needs to wait for this to finish and then use the cache.
        XCTAssertEqual(requestCount, 4)
        XCTAssertEqual(requestCountMeta, 2)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 2)
    }
    
    /// Test accessing a different APOD simultaneously, so that another Task is still running (metadata, thumbnail and image).
    func testAccessDifferentAll() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }
        guard let testDate2 = DateUtils.today(adding: -2) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        
        let expectFirstAPOD = expectation(description: "Load APOD from API")
        let expectSecondAPOD = expectation(description: "Load APOD from cache")
        let expectFirstAPODThumbnail = expectation(description: "Load APOD thumbnail from API")
        let expectSecondAPODThumbnail = expectation(description: "Load APOD thumbnail from cache")
        let expectFirstAPODImage = expectation(description: "Load APOD image from API")
        let expectSecondAPODImage = expectation(description: "Load APOD image from cache")
        
        /// Load APOD by request
        Task {
            let apod = try await cache.apod(for: testDate)
            await AsyncAssertEqual(await apod.date, testDate)
            expectFirstAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withThumbnail: true)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            expectFirstAPODThumbnail.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate, withImage: true)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
            expectFirstAPODImage.fulfill()
        }
        
        // Load different APOD should wait for the first load task to finish and then use cached APOD
        Task {
            let apod = try await cache.apod(for: testDate2)
            await AsyncAssertEqual(await apod.date, testDate2)
            expectSecondAPOD.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate2, withThumbnail: true)
            guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
            expectSecondAPODThumbnail.fulfill()
        }
        Task {
            let apod = try await cache.apod(for: testDate2, withImage: true)
            guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
            XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
            expectSecondAPODImage.fulfill()
        }
        
        await waitForExpectations(timeout: 1.0)
        
        // Access again, this time directly from cache, no other request running
        let apod = try await cache.apod(for: testDate, withThumbnail: true, withImage: true)
        guard let apodImageData = await apod.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        guard let apodThumbnailData = await apod.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod.date, testDate)
        XCTAssertEqual(apodImageData, APODDemoData.sampleImage2Data)
        XCTAssertEqual(apodThumbnailData, APODDemoData.sampleImageData)
        
        let apod2 = try await cache.apod(for: testDate2, withThumbnail: true, withImage: true)
        guard let apod2ImageData = await apod2.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        guard let apod2ThumbnailData = await apod2.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod2.date, testDate2)
        XCTAssertEqual(apod2ImageData, APODDemoData.sampleImage2Data)
        XCTAssertEqual(apod2ThumbnailData, APODDemoData.sampleImageData)
        
        // Both requests were started simultaneously, however still only one request to the API should be made. The other access needs to wait for this to finish and then use the cache.
        XCTAssertEqual(requestCount, 6)
        XCTAssertEqual(requestCountMeta, 2)
        XCTAssertEqual(requestCountThumbnail, 2)
        XCTAssertEqual(requestCountImage, 2)

    }
    
    
    // MARK: Reload
    
    /// Access data for APOD in three steps:
    /// 1. Load metadata
    /// 2. Load thumbnail (only thumbnail is loaded form API, APOD metadata is from cache)
    /// 3. Load image (only image is loaded form API, APOD metadata and thumbnail is from cache)
    func testAccessWithReload() async throws {
        guard let testDate = DateUtils.today(adding: -1) else { fatalError("Could not create date.") }

        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = sequenceMock()

        let cache = try APODCache(api: apodAPI)
        try await cache.load(pastDays: 1, withThumbnails: false, withImages: false)
        
        // Test access APOD from initial load
        let apod = try await cache.apod(for: testDate, withThumbnail: false, withImage: false)

        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 0)
        XCTAssertEqual(requestCountImage, 0)
        await AsyncAssertEqual(await apod.date, testDate)
        await AsyncAssertEqual(await apod.thumbnail, nil)
        await AsyncAssertEqual(await apod.image, nil)
        
        // Access again and load the thumbnail this time
        let apod2 = try await cache.apod(for: testDate, withThumbnail: true, withImage: false)
        
        // Thumbnail request should go to API, metadata should already be loaded
        XCTAssertEqual(requestCount, 2)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 0)
        guard let apod2ThumbnailData = await apod2.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod2.date, testDate)
        XCTAssertEqual(apod2ThumbnailData, APODDemoData.sampleImageData)
        await AsyncAssertEqual(await apod2.image, nil)
        
        // Access again and load the image this time
        let apod3 = try await cache.apod(for: testDate, withThumbnail: true, withImage: true)
        
        // Thumbnail request should go to API, metadata should already be loaded
        XCTAssertEqual(requestCount, 3)
        XCTAssertEqual(requestCountMeta, 1)
        XCTAssertEqual(requestCountThumbnail, 1)
        XCTAssertEqual(requestCountImage, 1)
        guard let apod3ThumbnailData = await apod3.thumbnail?.pngData() else { fatalError("Could not convert response image to Data object.") }
        guard let apod3ImageData = await apod3.image?.pngData() else { fatalError("Could not convert response image to Data object.") }
        await AsyncAssertEqual(await apod3.date, testDate)
        XCTAssertEqual(apod3ThumbnailData, APODDemoData.sampleImageData)
        XCTAssertEqual(apod3ImageData, APODDemoData.sampleImage2Data)
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
    
    /// - Returns: A request handler for the mock API, which counts the requests to the individual endpoints.
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

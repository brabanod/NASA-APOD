//
//  APODAPITests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 22.11.22.
//

import XCTest
@testable import NASA_APOD

final class APODAPITests: XCTestCase {
        
    var apodAPI: APODAPI!
    let apiBaseURL = "https://api.nasa.gov/planetary/apod"
    var apiKey: String!
    
    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [APODAPIMockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        apodAPI = try APODAPI(urlSession: urlSession)
        apiKey = (Bundle.main.object(forInfoDictionaryKey: "NASAAPIKey") as! String)
    }

    func testAPODByDateSuccess() async throws {
        let testDate = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        let testDateString = "2022-11-22"
        
        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = mockRequestHandler(
            expectedURL: "\(self.apiBaseURL)?api_key=\(self.apiKey!)&date=\(testDateString)",
            responseData: APODDemoData.singleAPODJSON.data(using: .utf8))
        
        // Call API
        let singleAPOD = try await apodAPI.apodByDate(testDate)
        
        // Test that demo data was returned correclty from API
        XCTAssertEqual(singleAPOD.date, testDate)
        XCTAssertEqual(singleAPOD.copyright, "Tommy Lease")
        XCTAssertEqual(singleAPOD.explanation, "Few star clusters this close to each other ...")
        XCTAssertEqual(singleAPOD.title, "A Double Star Cluster in Perseus")
        XCTAssertEqual(singleAPOD.imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        XCTAssertEqual(singleAPOD.thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
    }
    
    func testApodByDateRangeSuccess() async throws {
        let testStartDate = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 19))!
        let testStartDateString = "2022-11-19"
        let testEndDate = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        let testEndDateString = "2022-11-22"
        
        // Setup mock request handler
        APODAPIMockURLProtocol.requestHandler = mockRequestHandler(
            expectedURL: "\(self.apiBaseURL)?api_key=\(self.apiKey!)&start_date=\(testStartDateString)&end_date=\(testEndDateString)",
            responseData: APODDemoData.multipleAPODJSON.data(using: .utf8))
        
        // Call API
        let multipleAPOD = try await apodAPI.apodsByDateRange(start: testStartDate, end: testEndDate)
        
        // Test that demo data was returned correclty from API
        XCTAssertEqual(multipleAPOD.count, 4)
        
        let expectedDate2 = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 21))!
        XCTAssertEqual(multipleAPOD[2].date, expectedDate2)
        XCTAssertNil(multipleAPOD[2].copyright)
        XCTAssertEqual(multipleAPOD[2].explanation, "Stars can make beautiful patterns ...")
        XCTAssertEqual(multipleAPOD[2].title, "The Butterfly Nebula from Hubble")
        XCTAssertEqual(multipleAPOD[2].imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/Butterfly_HubbleOstling_3656.jpg"))
        XCTAssertEqual(multipleAPOD[2].thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/Butterfly_HubbleOstling_960.jpg"))
        
        let expectedDate3 = testEndDate
        XCTAssertEqual(multipleAPOD[3].date, expectedDate3)
        XCTAssertEqual(multipleAPOD[3].copyright, "Tommy Lease")
        XCTAssertEqual(multipleAPOD[3].explanation, "Few star clusters are this close to each other ...")
        XCTAssertEqual(multipleAPOD[3].title, "A Double Star Cluster in Perseus")
        XCTAssertEqual(multipleAPOD[3].imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        XCTAssertEqual(multipleAPOD[3].thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
    }
    
    func testThumbnailSuccess() async throws {
        guard let sampleAPOD = APODDemoData.sampleAPOD else { fatalError("Could not load sample APOD.") }
        guard let sampleImage = APODDemoData.sampleImage else { fatalError("Could not load sample image.") }
        guard let sampleImageData = sampleImage.pngData() else { fatalError("Could not transform image to Data object.") }
        
        APODAPIMockURLProtocol.requestHandler = mockRequestHandler(
            expectedURL: sampleAPOD.thumbnailURL.absoluteString,
            responseData: sampleImageData)
        
        // Call API
        let thumbnail = try await apodAPI.thumbnail(of: sampleAPOD)
        
        // Test that demo image was returned correctly from API
        guard let thumbnailData = thumbnail.pngData() else { fatalError("Could not convert response image to Data object.") }
        XCTAssertTrue(thumbnailData == sampleImageData)
    }
    
    func testImageSuccess() async throws {
        guard let sampleAPOD = APODDemoData.sampleAPOD else { fatalError("Could not load sample APOD.") }
        guard let sampleImage = APODDemoData.sampleImage else { fatalError("Could not load sample image.") }
        guard let sampleImageData = sampleImage.pngData() else { fatalError("Could not transform image to Data object.") }
        
        APODAPIMockURLProtocol.requestHandler = mockRequestHandler(
            expectedURL: sampleAPOD.imageURL.absoluteString,
            responseData: sampleImageData)
        
        // Call API
        let image = try await apodAPI.image(of: sampleAPOD)
        
        // Test that demo image was returned correctly from API
        guard let imageData = image.pngData() else { fatalError("Could not convert response image to Data object.") }
        XCTAssertTrue(imageData == sampleImageData)
    }
    
    // TODO: Test success cases for all API endpoint calls
    // TODO: Test all failure cases for API endpoint calls
    
    
    // This test is for manual testing purposes only, since it calls the real API endpoints.
    /*func testRealAPISample() async throws {
        let apodAPI = try APODAPI()
        
        // Load one and multiple APOD's
        print("Loading APOD's ...")
        let apod = try await apodAPI.apodByDate(Date())
        let apods = try await apodAPI.apodsByDateRange(
            start: Date(timeIntervalSince1970: 1668063213),
            end: Date(timeIntervalSince1970: 1668495213))
        
        // Load image
        print("Loading thumbnail ...")
        let thumbnail = try await apodAPI.thumbnail(of: apod)
        
        print("Loading image ...")
        let image = try await apodAPI.image(of: apod)
        
        print(apod, apods, apods.count, thumbnail, image)
    }*/
    
    
    
    // MARK: Helpers
    
    func mockRequestHandler(expectedURL: String, responseData: Data?) -> ((URLRequest) throws -> (HTTPURLResponse, Data?)) {
        return { (request: URLRequest) in
            guard let url = request.url else { fatalError("Could not extract url from request.") }
            
            // Test that request url is as expected, with expected query params
            XCTAssertEqual(url.absoluteString, expectedURL)
            
            // Respond with demo data
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
    }
}

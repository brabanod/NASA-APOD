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
        APODAPIMockURLProtocol.requestHandler = { request in
            guard let url = request.url else { fatalError("Could not extract url from request.") }
            
            // Test that request url is as expected, with expected query params
            XCTAssertEqual(
                url.absoluteString,
                "\(self.apiBaseURL)?api_key=\(self.apiKey!)&date=\(testDateString)"
            )
            
            // Respond with demo data
            let data = APODDemoData.singleAPODJSON.data(using: .utf8)
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // Call API
        let singleAPOD = try await apodAPI.apodByDate(testDate)
        
        // Test that demo data JSON string was decoded correctly into an APOD object
        XCTAssertEqual(singleAPOD.date, testDate)
        XCTAssertEqual(singleAPOD.copyright, "Tommy Lease")
        XCTAssertEqual(singleAPOD.explanation, "Few star clusters this close to each other ...")
        XCTAssertEqual(singleAPOD.title, "A Double Star Cluster in Perseus")
        XCTAssertEqual(singleAPOD.imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        XCTAssertEqual(singleAPOD.thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
    }
    
    // TODO: Test success cases for all API endpoint calls
    // TODO: Test all failure cases for API endpoint calls
    
    func testApodByDateRangeSuccess() {}
    
    func testThumbnailSuccess() {}
    
    func testImageSuccess() {}
    
    
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
}

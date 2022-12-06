//
//  APODAPIDefaultMock.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 29.11.22.
//

import Foundation
import UIKit

class APODAPIMockDefault: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        Task {
            do {
                // Extract URL
                guard let url = request.url else { fatalError("Could not extract url from request.") }
                let urlComponents = URLComponents(string: url.absoluteString)
                
                // Get date string query parameter from request
                var responseData: Data?
                
                if let dateString = urlComponents?.queryItems?.first(where: { $0.name == "date" })?.value {
                    let parseStrategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", timeZone: TimeZone.current)
                    
                    // Calculate index for metadata file using the difference from today to the request date
                    guard let today = DateUtils.today() else { fatalError("Could not process request.") }
                    let date = try Date(dateString, strategy: parseStrategy)
                    let dateDifference = abs(Calendar.current.dateComponents([.day], from: today, to: date).day ?? 0)
                    let index = dateDifference % 11
                    
                    // Load metadata
                    // Get file path for json file using the request date string as filename and load data
                    guard let jsonPath =
                            Bundle(for: Self.self).path(forResource: "SampleAPOD\(index)", ofType: ".json") ??
                            Bundle(for: Self.self).path(forResource: "SampleAPOD1", ofType: ".json") else { fatalError("Failed to load data.") }
                    let jsonURL = URL(fileURLWithPath: jsonPath)
                    
                    let data = try Data(contentsOf: jsonURL)
                    responseData = data
                    // Let it load a bit
                    try await Task.sleep(for: .milliseconds(500))
                } else {
                    // Load image
                    guard let imagePath = Bundle(for: Self.self).path(forResource: "SampleImage1", ofType: ".jpg") else { fatalError("Failed to load data.") }
                    let imageURL = URL(fileURLWithPath: imagePath)
                    
                    let data = try Data(contentsOf: imageURL)
                    responseData = data
                    // Let it load a bit
                    try await Task.sleep(for: .milliseconds(1100))
                }
                
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                
                // Send data to caller
                if let data = responseData {
                    client?.urlProtocol(self, didLoad: data)
                }
                
                // Finish request
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }
    
    override func stopLoading() {
        // This is called if the request gets canceled or completed.
    }
}

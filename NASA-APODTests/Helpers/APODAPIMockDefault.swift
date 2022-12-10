//
//  APODAPIDefaultMock.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 29.11.22.
//

import Foundation
import UIKit

class APODAPIMockDefault: URLProtocol {
    
    /// If set to true, data requested from here will be delayed. Otherwise responses will be sent instantly.
    static var simulateDelay: Bool = false
    
    /// If set to true, all requests will fail with a 400 error. Otherwise requests will be handled with success.
    static var failRequests: Bool = false
    
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
                
                let response: HTTPURLResponse!
                // Get date string query parameter from request
                var responseData: Data? = nil
                
                if Self.failRequests {
                   response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
                } else {
                    if let dateString = urlComponents?.queryItems?.first(where: { $0.name == "date" })?.value {
                        let parseStrategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", timeZone: TimeZone.current)
                        
                        // Calculate index for metadata file using the difference from today to the request date
                        let today = Date()
                        let date = try Date(dateString, strategy: parseStrategy)
                        let dateDifference = abs(Calendar.current.dateComponents([.day], from: today, to: date).day ?? 0)
                        let index = (dateDifference % 10) + 1
                        
                        // Load metadata
                        // Get file path for json file using the request date string as filename and load data
                        guard let jsonPath =
                                Bundle(for: Self.self).path(forResource: "SampleAPOD\(index)", ofType: ".json") ??
                                Bundle(for: Self.self).path(forResource: "SampleAPOD1", ofType: ".json") else { fatalError("Failed to load data.") }
                        let jsonURL = URL(fileURLWithPath: jsonPath)
                        
                        let data = try Data(contentsOf: jsonURL)
                        responseData = data
                        
                        // Let it load a bit if requested
                        if Self.simulateDelay {
                            try await Task.sleep(for: .milliseconds(500))
                        }
                    } else {
                        // Load image
                        guard let imagePath = Bundle(for: Self.self).path(forResource: "SampleImage1", ofType: ".jpg") else { fatalError("Failed to load data.") }
                        let imageURL = URL(fileURLWithPath: imagePath)
                        
                        let data = try Data(contentsOf: imageURL)
                        responseData = data
                        
                        // Let it load a bit if requested
                        if Self.simulateDelay {
                            try await Task.sleep(for: .milliseconds(1100))
                        }
                    }
                    
                    response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                }
                
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

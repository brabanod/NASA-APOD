//
//  APODAPIMockRequestHandler.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 26.11.22.
//

import XCTest
import Foundation

struct APODAPIMockRequestHandler {
    
    /// Creates a request handler for the mocked URLSession, which first checks that a given expected URL is sent and then responds with mock data.
    ///
    /// - Parameters:
    ///     - expectedURL: The URL that is expected from the given request.
    ///     - responseData: The data that should be sent to the client.
    ///
    /// - Returns: A closure which handles the request.
    static func success(data responseData: Data?, expectedURL: String? = nil) -> ((URLRequest) throws -> (HTTPURLResponse, Data?)) {
        return { (request: URLRequest) in
            guard let url = request.url else { fatalError("Could not extract url from request.") }
            
            // Test that request url is as expected, with expected query params
            if expectedURL != nil {
                XCTAssertEqual(url.absoluteString, expectedURL!)
            }
            
            // Respond with demo data
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, responseData)
        }
    }
    
    /// Creates a request handler for the mocked URLSession, which returns a given HTTP status code and no data.
    ///
    /// - Parameters:
    ///     - statusCode: An HTTP status code, which should be returned.
    ///
    /// - Returns: A closure which handles the request.
    static func empty(statusCode: Int, expectedURL: String? = nil) -> ((URLRequest) throws -> (HTTPURLResponse, Data?)) {
        return { (request: URLRequest) in
            guard let url = request.url else { fatalError("Could not extract url from request.") }
            
            // Test that request url is as expected, with expected query params
            if expectedURL != nil {
                XCTAssertEqual(url.absoluteString, expectedURL!)
            }
            
            // Respond with HTTP 400 status code
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
    }
}

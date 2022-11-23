//
//  APODAPIMockURLProtocol.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 23.11.22.
//

import Foundation

class APODAPIMockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
  
  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
      guard let handler = Self.requestHandler else {
          fatalError("Request handler not set.")
      }
      
      do {
          // Send request to handler
          let (response, data) = try handler(request)
          client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
          
          // Send data to caller
          if let data = data {
              client?.urlProtocol(self, didLoad: data)
          }
          
          // Finish request
          client?.urlProtocolDidFinishLoading(self)
      } catch {
          client?.urlProtocol(self, didFailWithError: error)
      }
  }

  override func stopLoading() {
    // This is called if the request gets canceled or completed.
  }
}

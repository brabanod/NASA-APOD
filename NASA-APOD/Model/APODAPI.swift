//
//  APODAPI.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 22.11.22.
//

import Foundation
import UIKit

enum APODAPIError: Error {
    case apiKeyUndefined(String)
    case urlCompositionFailure(String)
    case badResponse(String)
    case decodingFailure(String)
}

class APODAPI {
    let urlSession: URLSession
    let apiKey: String
    
    let apiBaseURL = "https://api.nasa.gov/planetary/apod"
    
    init(urlSession: URLSession = URLSession.shared) throws {
        self.urlSession = urlSession
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "NASAAPIKey") as? String else {
            throw APODAPIError.apiKeyUndefined("No API key was found. Specify an API key in Info.plist under the key 'NASAAPIKey'.")
        }
        self.apiKey = apiKey
    }
    
    /// Returns an APOD for a given date.
    ///
    /// - Parameters:
    ///     - date: The date for which to retrieve the APOD.
    /// - Returns: The `APOD` object for the specified date.
    func apodByDate(_ date: Date) async throws -> APOD {
        // Compose request URL
        guard var urlComponents = URLComponents(string: apiBaseURL) else {
            throw APODAPIError.urlCompositionFailure("Could not create URLComponents from apiBaseURL.")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "date", value: date.ISO8601Format(.iso8601Date(timeZone: TimeZone.current)))
        ]
        guard let url = urlComponents.url else {
            throw APODAPIError.urlCompositionFailure("Failed to compose URL for request. Could not create URL from URLComponents.")
        }
        
        // Query api with request
        let (apodData, response) = try await urlSession.data(for: URLRequest(url: url))
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw APODAPIError.badResponse("Response status code should be 200 but was \(statusCode != nil ? "\(statusCode!)" : "'undefined'").\n\(response)")
        }
        
        // Convert response into APOD object
        do {
            let apod = try JSONDecoder().decode(APOD.self, from: apodData)
            return apod
        } catch {
            let apodDataString = String(data: apodData, encoding: .utf8)
            throw APODAPIError.decodingFailure("Failed to decode APOD data.\n\(error)\nReceived data: \"\(apodDataString != nil ? apodDataString! : "Could not encode response data to string")\"")
        }
    }
    
    /// Returns an array of APOD's in a given date range. The date range is inclusive.
    ///
    /// - Parameters:
    ///     - startDate: The start date for the query.
    ///     - endDate: The end date for the query.
    /// - Returns: An array of `APOD` object, which contains the APOD's in the specified date range.
    func apodsByDateRange(start startDate: Date, end endDate: Date) async throws -> [APOD] {
        // Compose request URL
        guard var urlComponents = URLComponents(string: apiBaseURL) else {
            throw APODAPIError.urlCompositionFailure("Failed to compose URL for request. Could not create URLComponents from apiBaseURL.")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "start_date", value: startDate.ISO8601Format(.iso8601Date(timeZone: TimeZone.current))),
            URLQueryItem(name: "end_date", value: endDate.ISO8601Format(.iso8601Date(timeZone: TimeZone.current)))
        ]
        guard let url = urlComponents.url else {
            throw APODAPIError.urlCompositionFailure("Failed to compose URL for request. Could not create URL from URLComponents.")
        }
        
        // Query api with request
        let (apodsData, response) = try await urlSession.data(for: URLRequest(url: url))
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw APODAPIError.badResponse("Response status code should be 200 but was \(statusCode != nil ? "\(statusCode!)" : "'undefined'").\n\(response)")
        }
        
        // Convert response into APOD's array
        do {
            let apods = try JSONDecoder().decode([APOD].self, from: apodsData)
            return apods
        } catch {
            let apodsDataString = String(data: apodsData, encoding: .utf8)
            throw APODAPIError.decodingFailure("Failed to decode APOD data.\n\(error)\nResponse data: \(apodsDataString != nil ? apodsDataString! : "Could not encode response data to string")")
        }
    }
    
    /// Returns the thumbnail image of an APOD.
    ///
    /// - Parameters:
    ///     - apod: An `APOD` object, for which to retrieve the image.
    /// - Returns: The thumbnail image of the given `APOD`.
    func thumbnail(of apod: APOD) async throws -> UIImage {
        // Compose request URL
        let url = apod.thumbnailURL
        
        // Query api with request
        let (imageData, response) = try await urlSession.data(for: URLRequest(url: url))
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw APODAPIError.badResponse("Response status code should be 200 but was \(statusCode != nil ? "\(statusCode!)" : "'undefined'").\n\(response)")
        }
        
        // Convert response into UIImage
        guard let image = UIImage(data: imageData) else {
            throw APODAPIError.decodingFailure("Failed to create image from data.")
        }
        return image
    }
    
    /// Returns the full size image of an APOD.
    ///
    /// - Parameters:
    ///     - apod: An `APOD` object, for which to retrieve the image.
    /// - Returns: The full size image of the given `APOD`.
    func image(of apod: APOD) async throws -> UIImage {
        // Compose request URL
        let url = apod.imageURL
        
        // Query api with request
        let (imageData, response) = try await urlSession.data(for: URLRequest(url: url))
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw APODAPIError.badResponse("Response status code should be 200 but was \(statusCode != nil ? "\(statusCode!)" : "'undefined'").\n\(response)")
        }
        
        // Convert response into UIImage
        guard let image = UIImage(data: imageData) else {
            throw APODAPIError.decodingFailure("Failed to create image from data.")
        }
        return image
    }
}

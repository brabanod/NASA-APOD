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
    case queryCompositionFailure(String)
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
        return try await queryAPI(
            options: [URLQueryItem(name: "date", value: date.ISO8601Format(.iso8601Date(timeZone: TimeZone.current)))],
            type: APOD.self)
    }
    
    /// Returns an array of APODs in a given date range. The date range is inclusive.
    ///
    /// - Parameters:
    ///     - startDate: The start date for the query.
    ///     - endDate: The end date for the query.
    /// - Returns: An array of `APOD` object, which contains the APODs in the specified date range.
    func apodsByDateRange(start startDate: Date, end endDate: Date) async throws -> [APOD] {
        return try await queryAPI(
            options: [URLQueryItem(name: "start_date", value: startDate.ISO8601Format(.iso8601Date(timeZone: TimeZone.current))),
                      URLQueryItem(name: "end_date", value: endDate.ISO8601Format(.iso8601Date(timeZone: TimeZone.current)))],
            type: [APOD].self)
    }
    
    /// Returns the thumbnail image of an APOD and sets it as the thumbnail image of the given APOD. If the given APOD already has a thumbnail image loaded, the API query is skipped and the 'cached' thumbnail image is returned directly.
    ///
    /// - Parameters:
    ///     - apod: An `APOD` object, for which to retrieve the image.
    ///     - forceReload: If set to true, thumbnail image is loaded from API, even if it is already present in given APOD object.
    /// - Returns: The thumbnail image of the given `APOD`.
    func thumbnail(of apod: APOD, forceReload: Bool = false) async throws -> UIImage {
        // Load thumbnail image if needed or requested
        var thumbnail = await apod.thumbnail
        if thumbnail == nil || forceReload {
            thumbnail = try await queryImage(url: apod.thumbnailURL)
        }
        return thumbnail!
    }
    
    /// Returns the full size image of an APOD and sets it as the image of the given APOD. If the given APOD already has an image loaded, the API query is skipped and the 'cached' image is returned directly.
    ///
    /// - Parameters:
    ///     - apod: An `APOD` object, for which to retrieve the image.
    ///     - forceReload: If set to true, thumbnail image is loaded from API, even if it is already present in given APOD object.
    /// - Returns: The full size image of the given `APOD`.
    func image(of apod: APOD, forceReload: Bool = false) async throws -> UIImage {
        // Load image if needed or requested
        var image = await apod.image
        if image == nil || forceReload {
            image = try await queryImage(url: apod.imageURL)
        }
        return image!
    }
    
    
    // MARK: - Helpers
    
    /// Queries the API for an image.
    ///
    /// - Parameters:
    ///     - url: The URL where to get the image from.
    ///
    /// - Returns: A `UIImage` object, containing the image retrieved from the given URL.
    private func queryImage(url: URL) async throws -> UIImage {
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
    
    /// Queries the API for JSON data.
    ///
    /// - Parameters:
    ///     - options: An optional array of query parameters. **Note:** Don't include the API key as a query parameter, as this is automatically done by the function.
    ///     - type: The type into which the retrieved JSON should be decoded.
    /// - Returns: The retrieved data in form of the given type.
    private func queryAPI<T: Decodable>(options queryItems: [URLQueryItem]?, type: T.Type) async throws -> T {
        // Compose request URL
        guard var urlComponents = URLComponents(string: apiBaseURL) else {
            throw APODAPIError.queryCompositionFailure("Failed to compose URL for request. Could not create URLComponents from apiBaseURL.")
        }
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: apiKey)] + (queryItems ?? [])
        
        guard let url = urlComponents.url else {
            throw APODAPIError.queryCompositionFailure("Failed to compose URL for request. Could not create URL from URLComponents.")
        }
        
        // Query api with request
        let (responseData, response) = try await urlSession.data(for: URLRequest(url: url))
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw APODAPIError.badResponse("Response status code should be 200 but was \(statusCode != nil ? "\(statusCode!)" : "'undefined'").\n\(response)")
        }
        
        // Convert response into given type
        do {
            let result = try JSONDecoder().decode(T.self, from: responseData)
            return result
        } catch {
            let responseDataString = String(data: responseData, encoding: .utf8)
            throw APODAPIError.decodingFailure("Failed to decode APOD data.\n\(error)\nReceived data: \"\(responseDataString != nil ? responseDataString! : "Could not encode response data to string")\"")
        }
    }
}

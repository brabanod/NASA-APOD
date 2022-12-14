//
//  APOD.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 22.11.22.
//

import Foundation
import UIKit

/// This struct represents one element of an 'Astronomic Picture of the day'.
///
/// When `mediaType` is `.video`, the referenced video is stored in `thumbnailURL`.
actor APOD: Decodable, Hashable, Identifiable {
    
    enum MediaType: String, Decodable {
        case image = "image"
        case video = "video"
    }
    
    nonisolated func hash(into hasher: inout Hasher) {
      hasher.combine(date)
    }
    
    static func == (lhs: APOD, rhs: APOD) -> Bool {
        return lhs.date == rhs.date
    }
    
    let copyright: String?
    let date: Date
    let title: String
    let explanation: String
    let mediaType: MediaType
    
    let thumbnailURL: URL
    var thumbnail: UIImage?
    let imageURL: URL?
    var image: UIImage?
    
    nonisolated var id: Date {
        return date
    }
    
    private enum CodingKeys : String, CodingKey {
        case copyright, date, description, explanation, mediaType = "media_type", title, thumbnailURL = "url", imageURL = "hdurl"
    }
    
    func setThumbnail(_ thumbnail: UIImage?) {
        self.thumbnail = thumbnail
    }
    
    func setImage(_ image: UIImage?) {
        self.image = image
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        copyright = try values.decodeIfPresent(String.self, forKey: .copyright)
        explanation = try values.decode(String.self, forKey: .explanation)
        title = try values.decode(String.self, forKey: .title)
        mediaType = MediaType(rawValue: try values.decode(String.self, forKey: .mediaType)) ?? .image
        
        // Parse the date string
        let dateString = try values.decode(String.self, forKey: .date)
        let strategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", timeZone: TimeZone.current)
        date = try Date(dateString, strategy: strategy)
        
        // Convert URL strings to URLs
        thumbnailURL = try values.decode(URL.self, forKey: .thumbnailURL)
        imageURL = try values.decodeIfPresent(URL.self, forKey: .imageURL)
    }
}

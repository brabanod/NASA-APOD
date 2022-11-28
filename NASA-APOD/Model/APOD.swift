//
//  APOD.swift
//  NASA-APOD
//
//  Created by Braband, Pascal on 22.11.22.
//

import Foundation
import UIKit

/// This struct represents one element of an 'Astronomic Picture of the day'.
actor APOD: Decodable {
    var copyright: String?
    var date: Date
    var title: String
    var explanation: String
    
    var thumbnailURL: URL
    var thumbnail: UIImage?
    var imageURL: URL
    var image: UIImage?
    
    private enum CodingKeys : String, CodingKey {
        case copyright, date, description, explanation, title, thumbnailURL = "url", imageURL = "hdurl"
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
        
        // Parse the date string
        let dateString = try values.decode(String.self, forKey: .date)
        let strategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)", timeZone: TimeZone.current)
        date = try Date(dateString, strategy: strategy)
        
        // Convert URL strings to URLs
        thumbnailURL = try values.decode(URL.self, forKey: .thumbnailURL)
        imageURL = try values.decode(URL.self, forKey: .imageURL)
    }
}

//
//  APODDemoData.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 23.11.22.
//

import Foundation
@testable import NASA_APOD
import UIKit

class APODDemoData {
    
    static let singleAPODThumbnailURL = "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"
    static let singleAPODImageURL = "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"
    
    static let singleAPODJSON = """
        {
            "copyright":"Tommy Lease",
            "date":"2022-11-22",
            "explanation":"Few star clusters this close to each other ...",
            "hdurl":"\(singleAPODImageURL)",
            "media_type":"image",
            "service_version":"v1",
            "title":"A Double Star Cluster in Perseus",
            "url":"\(singleAPODThumbnailURL)"
        }
        """
    
    static let singleAPODVideoJSON = """
        {
            "copyright":"Tommy Lease",
            "date":"2022-11-22",
            "explanation":"Few star clusters this close to each other ...",
            "media_type":"video",
            "service_version":"v1",
            "title":"A Double Star Cluster in Perseus",
            "url":"https://youtube.com/something"
        }
        """
    
    static let multipleAPODJSON = """
        [
           {
              "copyright":"John Kraus",
              "date":"2022-11-19",
              "explanation":"When the Artemis 1 mission's Orion spacecraft ...",
              "hdurl":"https://apod.nasa.gov/apod/image/2211/DSC_3971-11-16-2022-Low-Res.jpg",
              "media_type":"image",
              "service_version":"v1",
              "title":"Artemis 1 Moonshot",
              "url":"https://apod.nasa.gov/apod/image/2211/DSC_3971-11-16-2022-1024o.jpg"
           },
           {
              "copyright":"Jeff Dai",
              "date":"2022-11-20",
              "explanation":"Why would the sky look like a giant target ...",
              "hdurl":"https://apod.nasa.gov/apod/image/2211/rippledsky_dai_960.jpg",
              "media_type":"image",
              "service_version":"v1",
              "title":"Airglow Ripples over Tibet",
              "url":"https://apod.nasa.gov/apod/image/2211/rippledsky_dai_960.jpg"
           },
           {
              "date":"2022-11-21",
              "explanation":"Stars can make beautiful patterns ...",
              "hdurl":"https://apod.nasa.gov/apod/image/2211/Butterfly_HubbleOstling_3656.jpg",
              "media_type":"image",
              "service_version":"v1",
              "title":"The Butterfly Nebula from Hubble",
              "url":"https://apod.nasa.gov/apod/image/2211/Butterfly_HubbleOstling_960.jpg"
           },
           {
              "copyright":"Tommy Lease",
              "date":"2022-11-22",
              "explanation":"Few star clusters are this close to each other ...",
              "hdurl":"https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg",
              "media_type":"image",
              "service_version":"v1",
              "title":"A Double Star Cluster in Perseus",
              "url":"https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"
           }
        ]
        """
    
    static let invalidDateAPODJSON = """
        {
            "copyright":"Tommy Lease",
            "date":"20221122",
            "explanation":"Few star clusters this close to each other ...",
            "hdurl":"https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg",
            "media_type":"image",
            "service_version":"v1",
            "title":"A Double Star Cluster in Perseus",
            "url":"https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"
        }
        """
    
    static var sampleAPOD: APOD? {
        guard let data = Self.singleAPODJSON.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(APOD.self, from: data)
    }
    
    static var sampleAPODVideo: APOD? {
        guard let data = Self.singleAPODVideoJSON.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(APOD.self, from: data)
    }
    
    static var mockAPOD1: APOD? {
        guard
            let path = Bundle(for: Self.self).path(forResource: "MockAPOD1", ofType: ".json"),
            let url = URL(filePath: path) as URL?,
            let data = try? Data(contentsOf: url)
        else { fatalError("Failed to get MockAPOD1.json.") }
        return try? JSONDecoder().decode(APOD.self, from: data)
    }
    
    static var sampleImage: UIImage {
        guard let path = Bundle(for: Self.self).path(forResource: "SampleImage", ofType: ".png") else { fatalError("Failed to get image path.") }
        guard let image = UIImage(contentsOfFile: path) else { fatalError("Failed to load image from file.") }
        return image
    }
    
    static var sampleImageData: Data {
        guard let data = APODDemoData.sampleImage.pngData() else { fatalError("Could not convert image to Data object.") }
        return data
    }
    
    static var sampleImage2: UIImage {
        guard let path = Bundle(for: Self.self).path(forResource: "SampleImage2", ofType: ".png") else { fatalError("Failed to get image path.") }
        guard let image = UIImage(contentsOfFile: path) else { fatalError("Failed to load image from file.") }
        return image
    }
    
    static var sampleImage2Data: Data {
        guard let data = APODDemoData.sampleImage2.pngData() else { fatalError("Could not convert image to Data object.") }
        return data
    }
    
    static var mockImage1: UIImage {
        guard let path = Bundle(for: Self.self).path(forResource: "MockImage1", ofType: ".jpg") else { fatalError("Failed to get image path.") }
        guard let image = UIImage(contentsOfFile: path) else { fatalError("Failed to load image from file.") }
        return image
    }
    
    static var mockImage1Data: Data {
        guard let data = APODDemoData.mockImage1.pngData() else { fatalError("Could not convert image to Data object.") }
        return data
    }
    
    static var apodLogoImage: UIImage {
        return UIImage(named: "APOD-Logo")!
    }
    
    static var apodLogoImageData: Data {
        guard let data = APODDemoData.apodLogoImage.pngData() else { fatalError("Could not convert image to Data object.") }
        return data
    }
    
    static func singleAPODJSON(with date: Date) -> String {
        return """
            {
                "copyright":"Tommy Lease",
                "date":"\(date.ISO8601Format(.iso8601Date(timeZone: TimeZone.current)))",
                "explanation":"Few star clusters this close to each other ...",
                "hdurl":"\(singleAPODImageURL)",
                "media_type":"image",
                "service_version":"v1",
                "title":"A Double Star Cluster in Perseus",
                "url":"\(singleAPODThumbnailURL)"
            }
        """
    }
}

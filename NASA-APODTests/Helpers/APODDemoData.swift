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
    
    static let singleAPODJSON = """
        {
            "copyright":"Tommy Lease",
            "date":"2022-11-22",
            "explanation":"Few star clusters this close to each other ...",
            "hdurl":"https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg",
            "media_type":"image",
            "service_version":"v1",
            "title":"A Double Star Cluster in Perseus",
            "url":"https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"
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
    
    static var sampleImage: UIImage? {
        guard let path = Bundle(for: Self.self).path(forResource: "SampleImage", ofType: ".png") else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    static var sampleImage2: UIImage? {
        guard let path = Bundle(for: Self.self).path(forResource: "SampleImage2", ofType: ".png") else { return nil }
        return UIImage(contentsOfFile: path)
    }

}

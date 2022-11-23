//
//  APODDemoData.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 23.11.22.
//

import Foundation

enum APODDemoData {
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
        """,
    
    static let multipleAPODJSON = """
        [{
            "copyright":"Tommy Lease",
            "date":"2022-11-22",
            "explanation":"Few star clusters this close to each other ...",
            "hdurl":"https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg",
            "media_type":"image",
            "service_version":"v1",
            "title":"A Double Star Cluster in Perseus",
            "url":"https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"
        },
        {
            "date":"2022-11-08",
            "explanation":"How many galaxies are interacting here ...",
            "hdurl":"https://apod.nasa.gov/apod/image/2211/WildTriplet_Hubble_3623.jpg",
            "media_type":"image",
            "service_version":"v1",
            "title":"Galaxies: Wild's Triplet from Hubble",
            "url":"https://apod.nasa.gov/apod/image/2211/WildTriplet_Hubble_960.jpg"
        }]
        """,
    
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

}

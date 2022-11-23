//
//  APODTests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 22.11.22.
//

import XCTest
@testable import NASA_APOD

final class APODTests: XCTestCase {
    
    let singleAPODJSON = """
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
    
    let multipleAPODJSON = """
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
        """
    
    let invalidDateAPODJSON = """
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

    func testSingleAPOD() throws {
        let singleAPOD = try JSONDecoder().decode(APOD.self, from: singleAPODJSON.data(using: .utf8)!)
        let expectedDate = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        XCTAssertEqual(singleAPOD.date, expectedDate)
        XCTAssertEqual(singleAPOD.copyright, "Tommy Lease")
        XCTAssertEqual(singleAPOD.explanation, "Few star clusters this close to each other ...")
        XCTAssertEqual(singleAPOD.title, "A Double Star Cluster in Perseus")
        XCTAssertEqual(singleAPOD.imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        XCTAssertEqual(singleAPOD.thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
    }
    
    func testMultipleAPOD() throws {
        let multipleAPOD = try JSONDecoder().decode([APOD].self, from: multipleAPODJSON.data(using: .utf8)!)
        
        let expectedDate0 = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        XCTAssertEqual(multipleAPOD[0].date, expectedDate0)
        XCTAssertEqual(multipleAPOD[0].copyright, "Tommy Lease")
        XCTAssertEqual(multipleAPOD[0].explanation, "Few star clusters this close to each other ...")
        XCTAssertEqual(multipleAPOD[0].title, "A Double Star Cluster in Perseus")
        XCTAssertEqual(multipleAPOD[0].imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        XCTAssertEqual(multipleAPOD[0].thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
        
        let expectedDate1 = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 08))!
        XCTAssertEqual(multipleAPOD[1].date, expectedDate1)
        XCTAssertNil(multipleAPOD[1].copyright)
        XCTAssertEqual(multipleAPOD[1].explanation, "How many galaxies are interacting here ...")
        XCTAssertEqual(multipleAPOD[1].title, "Galaxies: Wild's Triplet from Hubble")
        XCTAssertEqual(multipleAPOD[1].imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/WildTriplet_Hubble_3623.jpg"))
        XCTAssertEqual(multipleAPOD[1].thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/WildTriplet_Hubble_960.jpg"))
    }
    
    func testInvalidDateAPOD() throws {
        XCTAssertThrowsError(
            try JSONDecoder().decode(APOD.self, from: self.invalidDateAPODJSON.data(using: .utf8)!)
        ) { error in
            XCTAssertEqual(error.localizedDescription, "The value is invalid.")
        }
    }
}

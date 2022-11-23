//
//  APODTests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 22.11.22.
//

import XCTest
@testable import NASA_APOD

final class APODTests: XCTestCase {

    func testSingleAPOD() throws {
        let singleAPOD = try JSONDecoder().decode(APOD.self, from: APODDemoData.singleAPODJSON.data(using: .utf8)!)
        let expectedDate = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        XCTAssertEqual(singleAPOD.date, expectedDate)
        XCTAssertEqual(singleAPOD.copyright, "Tommy Lease")
        XCTAssertEqual(singleAPOD.explanation, "Few star clusters this close to each other ...")
        XCTAssertEqual(singleAPOD.title, "A Double Star Cluster in Perseus")
        XCTAssertEqual(singleAPOD.imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        XCTAssertEqual(singleAPOD.thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
    }
    
    func testMultipleAPOD() throws {
        let multipleAPOD = try JSONDecoder().decode([APOD].self, from: APODDemoData.multipleAPODJSON.data(using: .utf8)!)
        
        XCTAssertEqual(multipleAPOD.count, 4)
        
        let expectedDate2 = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 21))!
        XCTAssertEqual(multipleAPOD[2].date, expectedDate2)
        XCTAssertNil(multipleAPOD[2].copyright)
        XCTAssertEqual(multipleAPOD[2].explanation, "Stars can make beautiful patterns ...")
        XCTAssertEqual(multipleAPOD[2].title, "The Butterfly Nebula from Hubble")
        XCTAssertEqual(multipleAPOD[2].imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/Butterfly_HubbleOstling_3656.jpg"))
        XCTAssertEqual(multipleAPOD[2].thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/Butterfly_HubbleOstling_960.jpg"))
        
        let expectedDate3 = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        XCTAssertEqual(multipleAPOD[3].date, expectedDate3)
        XCTAssertEqual(multipleAPOD[3].copyright, "Tommy Lease")
        XCTAssertEqual(multipleAPOD[3].explanation, "Few star clusters are this close to each other ...")
        XCTAssertEqual(multipleAPOD[3].title, "A Double Star Cluster in Perseus")
        XCTAssertEqual(multipleAPOD[3].imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        XCTAssertEqual(multipleAPOD[3].thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
    }
    
    func testInvalidDateAPOD() throws {
        XCTAssertThrowsError(
            try JSONDecoder().decode(APOD.self, from: APODDemoData.invalidDateAPODJSON.data(using: .utf8)!)
        ) { error in
            XCTAssertEqual(error.localizedDescription, "The value is invalid.")
        }
    }
}

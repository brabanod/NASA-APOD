//
//  APODTests.swift
//  NASA-APODTests
//
//  Created by Braband, Pascal on 22.11.22.
//

import XCTest
@testable import NASA_APOD

final class APODTests: XCTestCase {

    func testSingleAPOD() async throws {
        let singleAPOD = try JSONDecoder().decode(APOD.self, from: APODDemoData.singleAPODJSON.data(using: .utf8)!)
        let expectedDate = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        await AsyncAssertEqual(await singleAPOD.date, expectedDate)
        await AsyncAssertEqual(await singleAPOD.copyright, "Tommy Lease")
        await AsyncAssertEqual(await singleAPOD.explanation, "Few star clusters this close to each other ...")
        await AsyncAssertEqual(await singleAPOD.title, "A Double Star Cluster in Perseus")
        await AsyncAssertEqual(await singleAPOD.mediaType, .image)
        await AsyncAssertEqual(await singleAPOD.imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        await AsyncAssertEqual(await singleAPOD.thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
    }
    
    func testSingleAPODVideo() async throws {
        let singleAPODVideo = try JSONDecoder().decode(APOD.self, from: APODDemoData.singleAPODVideoJSON.data(using: .utf8)!)
        let expectedDate = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        await AsyncAssertEqual(await singleAPODVideo.date, expectedDate)
        await AsyncAssertEqual(await singleAPODVideo.copyright, "Tommy Lease")
        await AsyncAssertEqual(await singleAPODVideo.explanation, "Few star clusters this close to each other ...")
        await AsyncAssertEqual(await singleAPODVideo.title, "A Double Star Cluster in Perseus")
        await AsyncAssertEqual(await singleAPODVideo.mediaType, .video)
        await AsyncAssertEqual(await singleAPODVideo.imageURL, nil)
        await AsyncAssertEqual(await singleAPODVideo.thumbnailURL, URL(string: "https://youtube.com/something"))
    }
    
    func testMultipleAPOD() async throws {
        let multipleAPOD = try JSONDecoder().decode([APOD].self, from: APODDemoData.multipleAPODJSON.data(using: .utf8)!)
        
        XCTAssertEqual(multipleAPOD.count, 4)
        
        let expectedDate2 = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 21))!
        await AsyncAssertEqual(await multipleAPOD[2].date, expectedDate2)
        await AsyncAssertEqual(await multipleAPOD[2].copyright, nil)
        await AsyncAssertEqual(await multipleAPOD[2].explanation, "Stars can make beautiful patterns ...")
        await AsyncAssertEqual(await multipleAPOD[2].title, "The Butterfly Nebula from Hubble")
        await AsyncAssertEqual(await multipleAPOD[2].imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/Butterfly_HubbleOstling_3656.jpg"))
        await AsyncAssertEqual(await multipleAPOD[2].thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/Butterfly_HubbleOstling_960.jpg"))
        
        let expectedDate3 = Calendar.current.date(from: DateComponents(year: 2022, month: 11, day: 22))!
        await AsyncAssertEqual(await multipleAPOD[3].date, expectedDate3)
        await AsyncAssertEqual(await multipleAPOD[3].copyright, "Tommy Lease")
        await AsyncAssertEqual(await multipleAPOD[3].explanation, "Few star clusters are this close to each other ...")
        await AsyncAssertEqual(await multipleAPOD[3].title, "A Double Star Cluster in Perseus")
        await AsyncAssertEqual(await multipleAPOD[3].imageURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_3756.jpg"))
        await AsyncAssertEqual(await multipleAPOD[3].thumbnailURL, URL(string: "https://apod.nasa.gov/apod/image/2211/DoubleCluster_Lease_960.jpg"))
    }
    
    func testInvalidDateAPOD() async throws {
        XCTAssertThrowsError(
            try JSONDecoder().decode(APOD.self, from: APODDemoData.invalidDateAPODJSON.data(using: .utf8)!)
        ) { error in
            XCTAssertEqual(error.localizedDescription, "The value is invalid.")
        }
    }
}

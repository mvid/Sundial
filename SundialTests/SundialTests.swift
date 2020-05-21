//
//  SundialTests.swift
//  SundialTests
//
//  Created by Mantas Vidutis on 5/19/20.
//  Copyright © 2020 Mantas Vidutis. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Sundial

class SundialTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testJulianConversion() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm Z"
        let testDate = formatter.date(from: "2013/01/01 00:30 Z")!
        let julianDay = julianDate(date: testDate)
        let testJulianDate = 2_456_293.520_833
        
        XCTAssertLessThan(abs(julianDay - testJulianDate), 0.001)
        
        let convertedDate = gregorianDate(date: julianDay)
        XCTAssertLessThan(abs(testDate.timeIntervalSince(convertedDate)), 10)
    }
    
    func testAstroCalculation() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm Z"
        let testDate = formatter.date(from: "2020/05/20 12:00 -0700")!
        
        let sanFrancisco = CLLocation(coordinate: CLLocationCoordinate2D(latitude:     37.773972, longitude: -122.431297), altitude: 10, horizontalAccuracy: 1, verticalAccuracy: 1, timestamp: testDate)
        
        let (sunrise, solarNoon, sunset) = sunTimesForDateLocation(date: testDate, location: sanFrancisco)
        let expectedSolarNoon = formatter.date(from: "2020/05/20 13:06 -0700")
        XCTAssertEqual(solarNoon, expectedSolarNoon!)
        
        let expectedSunrise = formatter.date(from: "2020/05/20 05:55 Z")
        let expectedSunset = formatter.date(from: "2020/05/20 20:17 Z")
        
        XCTAssertEqual(sunrise, expectedSunrise!)
        XCTAssertEqual(sunset, expectedSunset!)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

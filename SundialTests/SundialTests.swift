//
//  SundialTests.swift
//  SundialTests
//
//  Created by Mantas Vidutis on 5/19/20.
//  Copyright © 2020 Mantas Vidutis. All rights reserved.
//

import XCTest
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
    
    func testAstro() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm Z"
        let testDate = formatter.date(from: "2013/01/01 00:30 Z")!
        let julianDay = julianDayNumber(date: testDate)
        let testJulianDate = 2_456_293.520_833
        
        XCTAssertLessThan(abs(julianDay - testJulianDate), 0.001)
        
        let convertedDate = gregorianDate(date: julianDay)
        XCTAssertLessThan(abs(testDate.timeIntervalSince(convertedDate)), 10)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

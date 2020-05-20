//
//  Astro.swift
//  Sundial
//
//  Created by Mantas Vidutis on 11/12/19.
//  Copyright © 2019 Mantas Vidutis. All rights reserved.
//

import Foundation
import CoreLocation

func localSolarNoonOffset(longitude: CLLocationDegrees, date: Date) -> Double {
    let fracYear = fractionalYear(date: date)
    let eqTime = equationOfTime(fractionalYear: fracYear)
    let solarMidnight = (0 - (4 * longitude) - eqTime)
    return -1 * (solarMidnight / 60)
}

func localSolarMidnight(longitude: CLLocationDegrees, date: Date) -> Double {
    let fracYear = fractionalYear(date: date)
    let eqTime = equationOfTime(fractionalYear: fracYear)
    return (0 - (4 * longitude) - eqTime)
}


func fractionalYear(date: Date) -> Double {
    let calendar = Calendar.current
    let leap = isLeapYear(year: Int16(calendar.component(.year, from: date)))
    let day_of_year = calendar.ordinality(of: .day, in: .year, for: date)
    let hours = calendar.component(.hour, from: date)
    let day:Double = Double(day_of_year! - 1) + (Double(hours - 12) / 24)
    let total_days = Double(leap ? 366 : 365)
    return day * ((2 * Double.pi) / total_days)
}

func isLeapYear(year: Int16) -> Bool {
    if year % 400 == 0 {
        return true
    } else if year % 100 == 0 {
        return false
    }
    else if year % 4 == 0 {
        return true
    } else {
        return false
    }
}

func equationOfTime(fractionalYear: Double) -> Double {
    return 229.18 *
        (0.000075 -
            (-0.001868 * cos(fractionalYear)) -
            (0.032077 * sin(fractionalYear)) -
            (0.014615 * cos(fractionalYear)) -
            (0.040849 * sin(fractionalYear)))
}

// MARK - Attempt #2 from https://en.wikipedia.org/wiki/Sunrise_equation#Calculate_sunrise_and_sunset

func julienDay(date: Date) -> Double {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    let calculationDate = formatter.date(from: "2000/01/01 12:00")
    timeInterval = calculationDate?.timeIntervalSinceReferenceDate(
}

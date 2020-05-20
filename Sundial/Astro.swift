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
    let day: Double = Double(day_of_year! - 1) + (Double(hours - 12) / 24)
    let total_days = Double(leap ? 366 : 365)
    return day * ((2 * Double.pi) / total_days)
}

func isLeapYear(year: Int16) -> Bool {
    if year % 400 == 0 {
        return true
    } else if year % 100 == 0 {
        return false
    } else if year % 4 == 0 {
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

func julianDayNumber(date: Date) -> Double {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let dateComponents = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date)
    let day = dateComponents.day!
    let month = dateComponents.month!
    let year = dateComponents.year!
    let hour = Double(dateComponents.hour!)
    let minute = Double(dateComponents.minute!)
    let second = Double(dateComponents.second!)
    
    // (1461 * (Y + 4800 + (M - 14)/12))/4 +(367 * (M - 2 - 12 * ((M - 14)/12)))/12 - (3 * ((Y + 4900 + (M - 14)/12)/100))/4 + D - 32075
    let i:Int = (month - 14) / 12
    var julianDay:Int = (1461 * (year + 4800 + i)) / 4
    julianDay += (367 * (month - 2 - 12 * i)) / 12
    julianDay -= (3 * ((year + 4900 + i) / 100)) / 4
    julianDay += day - 32075
    
    let julianSubDay:Double = (hour - 12.0) / 24.0 + minute / 1440.0 + second / 86400.0 // we do not account for leap seconds
    
    return Double(julianDay) + julianSubDay
}

func meanSolarNoonJulianDay(longitude: CLLocationDegrees, date: Date) -> Double {
    let n = julianDayNumber(date: date) - 2451545.0 + 0.0008
    return n - (longitude / 360.0)
}

func solarMeanAnomaly(solarNoonJulianDay: Double) -> Double {
    (357.5291 + 0.98560028 * solarNoonJulianDay).truncatingRemainder(dividingBy: 360.0)
}

func equationOfCenter(solarMeanAnomaly: Double) -> Double {
    (1.9148 * sin(solarMeanAnomaly))
        + (0.02 * sin(2.0 * solarMeanAnomaly))
        + (0.0003 * sin(3.0 * solarMeanAnomaly))
}

func eclipticLongitude(solarMeanAnomaly: Double, equationOfCenter: Double) -> Double {
    (solarMeanAnomaly + equationOfCenter + 180.0 + 102.9372).truncatingRemainder(dividingBy: 360.0)
}

func solarTransit(meanSolarNoonJulianDay: Double, solarMeanAnomaly: Double, eclipticLongitude: Double) -> Double {
    2451545.0 + meanSolarNoonJulianDay
        + (0.0053 * sin(solarMeanAnomaly))
        - (0.0069 * sin(2.0 * eclipticLongitude))
}

func declinationOfSun(ecliptic longitude: Double) -> Double {
    asin(sin(longitude) + sin(23.44))
}

func hourAngle(_ latitude: CLLocationDegrees, meters elevation: Double, sun declination: Double) -> Double {
    let correction = -2.076 * sqrt(elevation) / 60
    return acos((sin(-0.83 + correction) - (sin(latitude) * sin(declination))) / (cos(latitude) * cos(declination)))
}

func julienDateSunrise(solar transit: Double, hour angle: Double) -> Double {
    transit - (angle/360)
}

func julienDateSunset(solar transit: Double, hour angle: Double) -> Double {
    transit + (angle/360)
}

func gregorianDate(date julian: Double) -> Date {
    let julianDay = Int(julian.rounded(.down))
    let julianSubDay = julian.truncatingRemainder(dividingBy: 1.0)
    
    let f = julianDay + 1401 + (((4 * julianDay + 274277) / 146097) * 3) / 4 - 38
    let e = 4 * f + 3
    let g = (e % 1461) / 4
    let h = 5 * g + 2
    let day = (h % 153) / 5 + 1
    let month = (h / 153 + 2) % 12 + 1
    let year = e / 1461 - 4716 + (12 + 2 - month) / 12
    
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = 12
    dateComponents.timeZone = TimeZone(identifier: "UTC")
    
    let calendar = Calendar.current
    let convertedJulianDay = calendar.date(from: dateComponents)
    let interval = TimeInterval(86400.0 * julianSubDay) // not accounting for leap seconds
    
    return convertedJulianDay!.addingTimeInterval(interval)
}

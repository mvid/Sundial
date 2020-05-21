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


func meanSolarNoonJulianDay(longitude: CLLocationDegrees, date: Date) -> Double {
    let jDate = JulianDate(gregorian: date)
    let n = jDate.julian - 2451545.0 + 0.0008
    return n - (longitude / 360.0)
}

func solarMeanAnomaly(solarNoonJulianDay: Double) -> Double {
    (357.5291 + (0.98560028 * solarNoonJulianDay)).truncatingRemainder(dividingBy: 360.0)
}

func equationOfCenter(solarMeanAnomaly: Double) -> Double {
    (1.9148 * sin(solarMeanAnomaly))
        + (0.0200 * sin(2.0 * solarMeanAnomaly))
        + (0.0003 * sin(3.0 * solarMeanAnomaly))
}

func eclipticLongitude(solarMeanAnomaly: Double, equationOfCenter: Double) -> Double {
    (solarMeanAnomaly + equationOfCenter + 180.0 + 102.9372).truncatingRemainder(dividingBy: 360.0)
}

func solarTransit(meanSolarNoonJulianDay: Double, solarMeanAnomaly: Double, eclipticLongitude: Double) -> JulianDate {
    let value = 2451545.0 + meanSolarNoonJulianDay
        + (0.0053 * sin(solarMeanAnomaly))
        - (0.0069 * sin(2.0 * eclipticLongitude))
    return JulianDate(julian: value)
}

func declinationOfSun(eclipticLongitude: Double) -> Double {
    asin(sin(eclipticLongitude) + sin(23.44))
}

func hourAngle(latitude: CLLocationDegrees, elevationMeters: Double, sunDeclination: Double) -> Double {
    let correction = -2.076 * sqrt(elevationMeters) / 60.0
    return acos((sin(-0.83 + correction) - (sin(latitude) * sin(sunDeclination))) / (cos(latitude) * cos(sunDeclination)))
}

func julianDateSunrise(solarTransit: JulianDate, hourAngle: Double) -> JulianDate {
    let jDate = solarTransit.julian - (hourAngle/360.0)
    return JulianDate(julian: jDate)
}

func julianDateSunset(solarTransit: JulianDate, hourAngle: Double) -> JulianDate {
    let jDate = solarTransit.julian + (hourAngle/360.0)
    return JulianDate(julian: jDate)
}

func solarTransitForDateLongitude(date: Date, longitude: CLLocationDegrees) -> (JulianDate, Double) {
    let snjd = meanSolarNoonJulianDay(longitude: longitude, date: date)
    let sma = solarMeanAnomaly(solarNoonJulianDay: snjd)
    let eoc = equationOfCenter(solarMeanAnomaly: sma)
    let el = eclipticLongitude(solarMeanAnomaly: sma, equationOfCenter: eoc)
    return (solarTransit(meanSolarNoonJulianDay: snjd, solarMeanAnomaly: sma, eclipticLongitude: el), el)
}

func sunTimesForDateLocation(date: Date, location: CLLocation) -> (sunriseDate: Date, zenithDate: Date, sunsetDate: Date) {
    
    let (st, el) = solarTransitForDateLongitude(date: date, longitude: location.coordinate.longitude)
    let dos = declinationOfSun(eclipticLongitude: el)
    let ha = hourAngle(latitude: location.coordinate.latitude, elevationMeters: location.altitude, sunDeclination: dos)
    
    let jSunrise = julianDateSunrise(solarTransit: st, hourAngle: ha)
    let jSunset = julianDateSunset(solarTransit: st, hourAngle: ha)
    
    return (jSunrise.gregorian, st.gregorian, jSunset.gregorian)
}

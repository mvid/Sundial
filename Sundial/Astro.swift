//
//  Astro.swift
//  Sundial
//
//  Created by Mantas Vidutis on 11/12/19.
//  Copyright © 2019 Mantas Vidutis. All rights reserved.
//

import Foundation
import CoreLocation

// MARK - Solar equations from https://en.wikipedia.org/wiki/Sunrise_equation#Calculate_sunrise_and_sunset

func meanSolarNoonJulianDay(longitude: CLLocationDegrees, date: Date) -> Double {
    let jDate = JulianDate(gregorian: date)
    let n = jDate.julian - 2451545.0 + 0.0008
    return n.rounded(.toNearestOrEven) - (longitude / 360.0)
}

func solarMeanAnomaly(solarNoonJulianDay: Double) -> Double {
    (357.5291 + (0.98560028 * solarNoonJulianDay)).truncatingRemainder(dividingBy: 360.0)
}

func degreesToRadians(degrees: Double) -> Double {
    degrees * .pi / 180.0
}

func sind(degrees: Double) -> Double {
    sin(degreesToRadians(degrees: degrees))
}

func cosd(degrees: Double) -> Double {
    cos(degreesToRadians(degrees: degrees))
}

func equationOfCenter(solarMeanAnomaly: Double) -> Double {
    let radians = degreesToRadians(degrees: solarMeanAnomaly)
    return (1.9148 * sin(radians))
        + (0.0200 * sin(2.0 * radians))
        + (0.0003 * sin(3.0 * radians))
}

func eclipticLongitude(solarMeanAnomaly: Double, equationOfCenter: Double) -> Double {
    (solarMeanAnomaly + equationOfCenter + 180.0 + 102.9372).truncatingRemainder(dividingBy: 360.0)
}

func solarTransit(meanSolarNoonJulianDay: Double, solarMeanAnomaly: Double, eclipticLongitude: Double) -> JulianDate {
    let value = 2451545.0 + meanSolarNoonJulianDay
        + (0.0053 * sind(degrees: solarMeanAnomaly))
        - (0.0069 * sind(degrees: 2.0 * eclipticLongitude))
    return JulianDate(julian: value)
}

func declinationOfSun(eclipticLongitude: Double) -> Double {
    let rightSide = sind(degrees: eclipticLongitude) * sind(degrees: 23.44)
    let radians = asin(rightSide)
    return radians * 180.0 / .pi
}

func hourAngle(latitude: CLLocationDegrees, elevationMeters: Double, sunDeclination: Double) -> Double {
    let correction = -2.076 * sqrt(elevationMeters) / 60.0
    let rightSide = (sind(degrees: -0.83 + correction) - (sind(degrees: latitude) * sind(degrees: sunDeclination)))
            / (cosd(degrees: latitude) * cosd(degrees: sunDeclination))
    return acos(rightSide) * 180.0 / .pi
}

func julianDateSunrise(solarTransit: JulianDate, hourAngle: Double) -> JulianDate {
    let jDate = solarTransit.julian - (hourAngle / 360.0)
    return JulianDate(julian: jDate)
}

func julianDateSunset(solarTransit: JulianDate, hourAngle: Double) -> JulianDate {
    let jDate = solarTransit.julian + (hourAngle / 360.0)
    return JulianDate(julian: jDate)
}


func sunTimesForDateLocation(date: Date, location: CLLocation) -> (sunriseDate: Date, zenithDate: Date, sunsetDate: Date) {
    let snjd = meanSolarNoonJulianDay(longitude: location.coordinate.longitude, date: date)
    let sma = solarMeanAnomaly(solarNoonJulianDay: snjd)
    let eoc = equationOfCenter(solarMeanAnomaly: sma)
    let el = eclipticLongitude(solarMeanAnomaly: sma, equationOfCenter: eoc)
    let sTransit = solarTransit(meanSolarNoonJulianDay: snjd, solarMeanAnomaly: sma, eclipticLongitude: el)
    let dos = declinationOfSun(eclipticLongitude: el)
    let ha = hourAngle(latitude: location.coordinate.latitude, elevationMeters: location.altitude, sunDeclination: dos)

    let jSunrise = julianDateSunrise(solarTransit: sTransit, hourAngle: ha)
    let jSunset = julianDateSunset(solarTransit: sTransit, hourAngle: ha)
    
    return (jSunrise.gregorian, sTransit.gregorian, jSunset.gregorian)
}

//
//  Astro.swift
//  Sundial
//
//  Created by Mantas Vidutis on 11/12/19.
//  Copyright © 2019 Mantas Vidutis. All rights reserved.
//

import Foundation
import CoreLocation

func local_solar_noon_offset(longitude: CLLocationDegrees, date: Date) -> Double {
    let frac_year = fractional_year(date: date)
    let eq_time = equation_of_time(fractional_year: frac_year)
    let solar_midnight = (0 - (4 * longitude) - eq_time)
    return -1 * (solar_midnight / 60)
}

func fractional_year(date: Date) -> Double {
    let calendar = Calendar.current
    let leap = leap_year(year: Int16(calendar.component(.year, from: date)))
    let day_of_year = calendar.ordinality(of: .day, in: .year, for: date)
    let hours = calendar.component(.hour, from: date)
    let day:Double = Double(day_of_year! - 1) + (Double(hours - 12) / 24)
    let total_days = Double(leap ? 366 : 365)
    return day * ((2 * Double.pi) / total_days)
}

func leap_year(year: Int16) -> Bool {
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

func equation_of_time(fractional_year: Double) -> Double {
    return 229.18 *
        (0.000075 -
            (-0.001868 * cos(fractional_year)) -
            (0.032077 * sin(fractional_year)) -
            (0.014615 * cos(fractional_year)) -
            (0.040849 * sin(fractional_year)))
}

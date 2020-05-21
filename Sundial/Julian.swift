//
//  Julian.swift
//  Sundial
//
//  Created by Mantas Vidutis on 5/21/20.
//  Copyright © 2020 Mantas Vidutis. All rights reserved.
//

import Foundation

public struct JulianDate : Comparable, Equatable, CustomStringConvertible {
    private var value: Double
    
    public init(gregorian: Date) {
        self.value = JulianDate.gregorianToJulian(gregorian: gregorian)
    }
    
    public init(julian: Double) {
        self.value = julian
    }
    
    var julian: Double {
        get {
            return self.value
        }
    }
    
    var gregorian: Date {
        get {
            return JulianDate.julianToGregorian(julian: self.value)
        }
    }
    
    public var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return String(format:"%f", self.julian) + ", " + formatter.string(from: self.gregorian)
    }
    
    public static func < (lhs: JulianDate, rhs: JulianDate) -> Bool {
        return lhs.value < rhs.value
    }
    
    private static func julianToGregorian(julian: Double) -> Date {
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
    
    private static func gregorianToJulian(gregorian: Date) -> Double {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let dateComponents = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: gregorian)
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
}

//
//  LocationManager.swift
//  Sundial
//
//  Created by Mantas Vidutis on 11/12/19.
//  Copyright © 2019 Mantas Vidutis. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
import WatchConnectivity

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    let objectWillChange = PassthroughSubject<Void, Never>()

    override init() {
        self.location = CLLocation(latitude: 54.687157, longitude: 25.279652)
        self.offsetDateNow = Date()

        super.init()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // technically 7km/s offset at equator, 2.8km/s offset at arctic circle
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()

        let _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { timer in
            self.offsetDateNow = self.offsetDate(date: self.dateNow)
        })
    }

    @Published var status: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var location: CLLocation {
        willSet {
            objectWillChange.send()
        }
    }

    var dateNow: Date {
        get {
            return Date()
        }
    }

    @Published var offsetDateNow: Date {
        willSet {
            objectWillChange.send()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.location = location
    }

    func locationOffset(date: Date) -> Double {
        self.location.coordinate.longitude / 15.0
    }

    func solarOffset(date: Date) -> Double {
        let (_, solarTransit, _) = sunTimesForDateLocation(date: date, location: self.location)

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let dc = calendar.dateComponents([
            Calendar.Component.day, Calendar.Component.month, Calendar.Component.year,
            Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second,
            Calendar.Component.timeZone], from: date)

        var dateNoonDC = DateComponents()
        dateNoonDC.year = dc.year!
        dateNoonDC.month = dc.month!
        dateNoonDC.day = dc.day!
        dateNoonDC.hour = 12
        dateNoonDC.timeZone = dc.timeZone!
        let dateNoon = calendar.date(from: dateNoonDC)!

        let interval = dateNoon.timeIntervalSince(solarTransit)
        return interval / 60 / 60
    }

    func solarDayOffset(date: Date) -> Double {
        let (sunrise, solarTransit, sunset) = sunTimesForDateLocation(date: date, location: self.location)

        var dayOffset = 0.0
        if (sunrise < date) && (sunset > date) {
            let dayPassed = date.timeIntervalSince(sunrise)
            let dayLeft = sunset.timeIntervalSince(date)
            let percent = (dayPassed / (dayPassed + dayLeft))
            dayOffset = (percent * 12) - 6
        } else if (sunrise > date) {
            let dayBefore = date.addingTimeInterval(-24 * 60 * 60)
            let (_, _, dbSunset) = sunTimesForDateLocation(date: dayBefore, location: self.location)
            let nightPassed = date.timeIntervalSince(dbSunset)
            let nightLeft = sunrise.timeIntervalSince(date)
            let percent = (nightPassed / (nightPassed + nightLeft))
            dayOffset = -(percent * 12) - 6
        } else {
            let nextDay = date.addingTimeInterval(24 * 60 * 60)
            let (ndSunrise, _, _) = sunTimesForDateLocation(date: nextDay, location: self.location)
            let nightPassed = date.timeIntervalSince(sunset)
            let nightLeft = ndSunrise.timeIntervalSince(date)
            let percent = (nightPassed / (nightPassed + nightLeft))
            dayOffset = (percent * 12) + 6
        }

        return self.solarOffset(date: date) + dayOffset
    }

    func offsetDate(date: Date) -> Date {
        let offset = self.offset(date: date)

        let seconds = date.timeIntervalSince1970
        return Date(timeIntervalSince1970: (seconds + (offset * 60 * 60)))
    }

    func offset(date: Date) -> Double {
        let defaults = UserDefaults.standard
        defaults.synchronize()
        let method = defaults.string(forKey: "SundialCalculationMethod")
        var offset = 0.0

        switch method {
        case "SOLAR_NOON":
            offset = self.solarOffset(date: date)
            break;
        case "SOLAR_DAY":
            offset = self.solarDayOffset(date: date)
            break;
        default:
            offset = self.locationOffset(date: date)
            break;
        }

        return offset
    }

    // gives a reverse offset date, for use with the relative date
    // complication templates
    func reverseOffsetDate(date: Date) -> Date {
        let offset = self.offset(date: date)
        let seconds = date.timeIntervalSince1970
        return Date(timeIntervalSince1970: (seconds - (offset * 60 * 60)))
    }
}
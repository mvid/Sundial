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
            self.offsetDateNow = self.locationOffsetDate(date: self.dateNow)
        })
    }
    
    @Published var status: CLAuthorizationStatus? {
        willSet { objectWillChange.send() }
    }
    
    @Published var location: CLLocation {
        willSet { objectWillChange.send() }
    }
    
    var offset: Double {
        get {
            return self.locationOffset(date: Date())
        }
    }
    
    var dateNow: Date {
        get {
            return Date()
        }
    }
    
    @Published var offsetDateNow: Date {
        willSet { objectWillChange.send() }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationOffset(date: Date) -> Double {
        return localSolarNoonOffset(longitude: self.location.coordinate.longitude, date: date)
    }
    
    func locationOffsetDate(date: Date) -> Date {
        let offset = self.locationOffset(date: date)
        let seconds = date.timeIntervalSince1970
        return Date(timeIntervalSince1970: (seconds + (offset * 60 * 60)))
    }
    
    // gives a reverse offset date, for use with the relative date
    // complication templates
    func locationReverseOffsetDate(date: Date) -> Date {
        let offset = self.locationOffset(date: date)
        let seconds = date.timeIntervalSince1970
        return Date(timeIntervalSince1970: (seconds - (offset * 60 * 60)))
    }
}


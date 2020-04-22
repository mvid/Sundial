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
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers // technically 7km/s offset at equator, 2.8km/s offset at arctic circle
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    @Published var status: CLAuthorizationStatus? {
        willSet { objectWillChange.send() }
    }
    
    @Published var location: CLLocation? {
        willSet { objectWillChange.send() }
    }
    
    @Published var offset: Double? {
        willSet { objectWillChange.send() }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("updated", location)
        self.location = location
        self.offset = self.locationOffset(date: Date())
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(), userInfo: nil) { err in
            if let err = err {
                print(err)
            }
        }
    }
    
    func locationOffset(date: Date) -> Double? {
        if self.location != nil {
            return local_solar_noon_offset(longitude: self.location!.coordinate.longitude, date: date)
        } else {
            return nil
        }
    }
    
    func locationOffsetDate(date: Date) -> Date? {
        let offset = self.locationOffset(date: date)
        if offset == nil {
            return nil
        }
        let seconds = date.timeIntervalSince1970
        return Date(timeIntervalSince1970: (seconds + (offset! * 60 * 60)))
    }
}


//
//  ContentView.swift
//  Sundial
//
//  Created by Mantas Vidutis on 11/12/19.
//  Copyright © 2019 Mantas Vidutis. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @ObservedObject var lm = LocationManager()
    
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var latitude: String  { return("\(lm.location.coordinate.latitude)") }
    var longitude: String { return("\(lm.location.coordinate.longitude)") }
    var status: String    { return("\(String(describing: lm.status))") }
    var current_time: String {
        return("\(String(describing: lm.dateNow))")
    }
    var offset_time : String {
        return("\(String(describing: lm.offsetDateNow))")
    }
    var offset: String    { return("\(String(describing: lm.offset))") }
    
    
    var body: some View {
        VStack {
            Text("Hello World!")
            Text("Latitude: \(self.latitude)")
            Text("Longitude: \(self.longitude)")
            Text("Status: \(self.status)")
            Text("Current: \(self.current_time)")
            Text("Offset: \(self.offset_time)")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

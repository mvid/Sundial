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
    var date = Date()
    
    var latitude: String  { return("\(lm.location?.coordinate.latitude ?? 0)") }
    var longitude: String { return("\(lm.location?.coordinate.longitude ?? 0)") }
    var status: String    { return("\(String(describing: lm.status))") }
    var current_time: String {
        return("\(date)")
    }
    var offset_time : String {
        let seconds = date.timeIntervalSince1970
        let offset_time = Date(timeIntervalSince1970: (seconds + ((lm.offset ?? 0) * 60 * 60)))
        return("\(offset_time)")
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

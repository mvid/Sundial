//
//  ContentView.swift
//  Sundial WatchKit Extension
//
//  Created by Mantas Vidutis on 11/12/19.
//  Copyright © 2019 Mantas Vidutis. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var lm = LocationManager()
    
    var offset: String {
        ("\(String(describing: lm.offset))")
    }
    var utc: String {
        ("\(String(describing: lm.dateNow))")
    }
    var date: String {
        ("\(String(describing: lm.offsetDateNow))")
    }
    var body: some View {
        VStack {
            Text("Sundial")
            Text(offset)
            Text(utc)
            Text(date)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

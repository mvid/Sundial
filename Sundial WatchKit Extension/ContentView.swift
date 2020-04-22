//
//  ContentView.swift
//  Sundial WatchKit Extension
//
//  Created by Mantas Vidutis on 11/12/19.
//  Copyright © 2019 Mantas Vidutis. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var currentDate = Date()
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    @ObservedObject var lm = LocationManager()
    var offset: String {
        ("\(String(describing: lm.offset))")
    }
    var utc: String {
        ("\(String(describing: currentDate))")
    }
    var date: String {
        ("\(String(describing: lm.locationOffsetDate(date: currentDate)))")
    }
    var body: some View {
        VStack {
            Text("Sundial")
            Text(utc)
            Text(date)
        }.onReceive(timer) { input in
            self.currentDate = input
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

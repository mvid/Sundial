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
    let myDelegate = WKExtension.shared().delegate as! ExtensionDelegate
    var offset: String    { return("\(String(describing: lm.offset))") }
    var body: some View {
        VStack {
            Text("Hello World")
            Text(offset)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

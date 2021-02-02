//
//  ContentView.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/7/20.
//

import SwiftUI
import WineRegionLib

struct ContentView: View {
    let wineMapView: WineMapView
    @EnvironmentObject var dataStore: DataStore
    @State var selectedMapType: MapTypeSelection = .normal
    var body: some View {
        ZStack {
            MapView(mapView: wineMapView, selectedMapType: $selectedMapType, dataStore: dataStore)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                MapSelectionControl(selectedMapType: $selectedMapType)
                ChateauxSearchControl()
            }.padding() 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(wineMapView: WineMapView(dataStore: DataStore()))
    }
}

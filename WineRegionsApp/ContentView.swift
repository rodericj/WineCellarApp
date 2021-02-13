//
//  ContentView.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/7/20.
//

import SwiftUI
import WineRegionLib

import MapboxMaps

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var wineMapView: WineMapView
    @EnvironmentObject var mapboxMapView: MapboxMapView
   
    var body: some View {
        ZStack {
            if dataStore.selectedMapType.title != "topo" {
                MapKitBasedMapView(mapView: wineMapView, selectedMapType: $dataStore.selectedMapType)
                    .edgesIgnoringSafeArea(.all)
            } else {
                MapboxMapBasedViewRepresentable(mapView: mapboxMapView,
                                                selectedMapType: $dataStore.selectedMapType)
            }
            VStack {
                MapSelectionControl(selectedMapType: $dataStore.selectedMapType)
                ChateauxSearchControl()
            }.padding() 
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

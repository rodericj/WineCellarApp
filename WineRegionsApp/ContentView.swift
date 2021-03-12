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
    @EnvironmentObject var mapboxMapView: MapboxMapView

    var body: some View {
        ZStack {
            MapboxMapBasedViewRepresentable(mapView: mapboxMapView)
            VStack {
                MapSelectionControl(selectedMapType: $dataStore.selectedMapType,
                                    selectedMapExaggeration: $dataStore.selectedExaggerationLevel,
                                    isRegionColorOn: $dataStore.isRegionColorOn)
//                ChateauxSearchControl()
            }.padding() 
        }
        .navigationBarTitle(Text(verbatim: dataStore.currentRegionNavTitle))
        .ignoresSafeArea()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

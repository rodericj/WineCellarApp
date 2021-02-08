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
    @State var selectedMapType: MapTypeSelection = .normal
   
    var body: some View {
        ZStack {
            if selectedMapType.title != "topo" {
                MapKitBasedMapView(mapView: wineMapView, selectedMapType: $selectedMapType)
                    .edgesIgnoringSafeArea(.all)
            } else {
                MapboxMapBasedViewRepresentable(mapView: mapboxMapView,
                                                selectedMapType: $selectedMapType)
            }
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if let searchString = UIPasteboard.general.string {
                            dataStore.newRegionOSMID.send(searchString)
                        }
                    }) {
                        Image(systemName: "calendar")
                            .frame(width: 60, height: 60, alignment: .center)
                    }
                }
                Spacer()
                MapSelectionControl(selectedMapType: $selectedMapType)
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

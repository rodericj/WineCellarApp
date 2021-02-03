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
                HStack {
                    Spacer()
                    Button(action: {
                        if let searchString = UIPasteboard.general.string {
                            dataStore.newRegionOSMID.send(searchString)
                        }
                        else {
                            print("no search string in pasteboard")
                            dataStore.newRegionOSMID.send("127321")
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
        ContentView(wineMapView: WineMapView(dataStore: DataStore()))
    }
}

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
    @ObservedObject var viewModel: WineRegion
    @State var selectedMapType: MapTypeSelection = .normal

    var body: some View {
        ZStack {
            MapView(mapView: wineMapView, selectedMapType: $selectedMapType)
                .edgesIgnoringSafeArea(.all)
            MapSelectionControl(selectedMapType: $selectedMapType)
            SearchControl()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(wineMapView: WineMapView(wineRegionLib: WineRegion()),
                    viewModel: WineRegion())
    }
}

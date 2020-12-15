//
//  ContentView.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/7/20.
//

import SwiftUI
import WineRegionLib

struct MapSelectionControl: View {
    @Binding var selectedMapType: MapTypeSelection
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ExpandableButtonPanel(primaryItem: $selectedMapType,
                                      secondaryItems: [.sat, .topo, .normal])
                    .padding()

            }
        }
    }
}

struct ContentView: View {
    let wineMapView: WineMapView
    @ObservedObject var viewModel: WineRegionLib.WineRegion
    @State var selectedMapType: MapTypeSelection = .normal
    var body: some View {
        switch viewModel.regionMaps {
        case .loading(let value):
            VStack {
                ProgressView(value: value)
                MapView(mapView: wineMapView, selectedMapType: $selectedMapType)
                    .edgesIgnoringSafeArea(.all)
            }
        default:
            ZStack {
                MapView(mapView: wineMapView, selectedMapType: $selectedMapType)
                    .edgesIgnoringSafeArea(.all)
                MapSelectionControl(selectedMapType: $selectedMapType)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(wineMapView: WineMapView(wineRegionLib: WineRegion()),
                    viewModel: WineRegion())
    }
}

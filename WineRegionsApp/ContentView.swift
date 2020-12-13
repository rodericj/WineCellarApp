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
    @ObservedObject var viewModel: WineRegionLib.WineRegion
            
    var body: some View {
        switch viewModel.regionMaps {
        case .loading(let value):
            ProgressView(value: value)
            MapView(mapView: wineMapView)
                .edgesIgnoringSafeArea(.all)

        default:
            MapView(mapView: wineMapView)
                .edgesIgnoringSafeArea(.all)
        }
    }

}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

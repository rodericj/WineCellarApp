//
//  RegionNavigation.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/13/20.
//

import SwiftUI
import WineRegionLib
import Combine
struct RegionNavigation: View {
    @EnvironmentObject private var wineRegionLib: WineRegion
    let wineMapView: WineMapView
    var body: some View {
        NavigationView {
            RegionList(lib: wineRegionLib)
                .navigationBarTitle(Text("Regions"))
                .navigationViewStyle(StackNavigationViewStyle())

            // Detail view
            ContentView(wineMapView: wineMapView,
                        viewModel: wineRegionLib)
        }
    }
}

struct RegionNavigation_Previews: PreviewProvider {
    static var previews: some View {
        RegionNavigation(wineMapView: WineMapView(wineRegionLib: WineRegion()))
    }
}

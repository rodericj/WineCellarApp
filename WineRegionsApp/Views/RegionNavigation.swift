//
//  RegionNavigation.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/13/20.
//

import SwiftUI
import WineRegionLib

struct RegionNavigation: View {
    private let wineRegionLib = WineRegionLib.WineRegion()

    var body: some View {
        NavigationView {
            RegionList(lib: wineRegionLib)
                .navigationBarTitle(Text("Regions"))
                .navigationViewStyle(StackNavigationViewStyle())

            // Detail view
            ContentView(wineMapView: WineMapView(wineRegionLib: wineRegionLib),
                        viewModel: wineRegionLib)
        }
    }
}

struct RegionNavigation_Previews: PreviewProvider {
    static var previews: some View {
        RegionNavigation()
    }
}

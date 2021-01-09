//
//  RegionNavigation.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/13/20.
//

import SwiftUI
import WineRegionLib
import Combine
struct RegionListNavButtons: View {
    @EnvironmentObject var dataStore: DataStore
    var body: some View {
        if dataStore.regionTreeLoadingProgress < 1 && dataStore.regionTreeLoadingProgress > 0 {
            ProgressView()
        } else {
            EmptyView()
        }
    }
}

struct RegionNavigation: View {
    @EnvironmentObject private var wineRegionLib: WineRegion
    let wineMapView: WineMapView
    var body: some View {
        NavigationView {
            RegionList(lib: wineRegionLib)
                .navigationBarTitle(Text("Regions"))
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarItems(trailing: RegionListNavButtons())

            // Detail view
            ContentView(wineMapView: wineMapView,
                        viewModel: wineRegionLib)
                .navigationBarHidden(true)
        }
    }
}

struct RegionNavigation_Previews: PreviewProvider {
    static var previews: some View {
        RegionNavigation(wineMapView: WineMapView(dataStore: DataStore()))
    }
}

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
    @EnvironmentObject var treeWrapper: WineTreeWrapper
    var body: some View {
        if treeWrapper.loadingProgress < 1 && treeWrapper.loadingProgress > 0 {
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
        RegionNavigation(wineMapView: WineMapView(wineRegionLib: WineRegion()))
    }
}

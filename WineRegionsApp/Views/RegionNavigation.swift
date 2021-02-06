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
        HStack {
            if dataStore.regionTreeLoadingProgress < 1 && dataStore.regionTreeLoadingProgress > 0 {
                ProgressView()
            } else {
                EmptyView()
            }
            Button(action: {
                dataStore.getRegionTree()
            }) {
                Image(systemName: "arrow.clockwise")
            }
            if dataStore.isLeafNodeRegion {
                Button(action: {
                    dataStore.deleteSelectedRegion()
                }) {
                    Image(systemName: "delete.right")
                }
            }
        }
    }
}

struct RegionNavigation: View {
    @EnvironmentObject private var wineRegionLib: WineRegion
    let wineMapView: WineMapView
    var body: some View {
        NavigationView {
            RegionList()
                .navigationBarTitle(Text("Regions"))
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarItems(trailing: RegionListNavButtons())

            // Detail view
            ContentView(wineMapView: wineMapView)
                .navigationBarHidden(false)
        }
    }
}

struct RegionNavigation_Previews: PreviewProvider {
    static var previews: some View {
        RegionNavigation(wineMapView: WineMapView(dataStore: DataStore()))
    }
}

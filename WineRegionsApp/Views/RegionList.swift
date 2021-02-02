//
//  RegionList.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/13/20.
//

import SwiftUI
import WineRegionLib

struct MakeView: View {
    let make: () -> AnyView
    var body: some View {
        make()
    }
}

struct RegionList: View {
    @EnvironmentObject var dataStore: DataStore

    var regionsResults: [RegionJson] {
        dataStore.regionTree
    }

    var body: some View {
//        SearchBar(placeholder: "Search", searchEntry: $dataStore.regionFilter.filterString)
//            .padding()
        List(regionsResults, children: \.children) { item in
            RegionRow(region: item, title: item.title, dataStore: dataStore)
        }
    }
}

struct RegionRow: View {
    @EnvironmentObject var wineMapView: WineMapView
    let region: RegionJson
    let title: String
    @State private var isShowingDetailView = false
    let dataStore: WineRegionProviding
    var body: some View {
            HStack {
                Text(region.title.capitalized).font(.title3)
                Spacer()
                NavigationLink(destination: ContentView(wineMapView: wineMapView),
                               isActive: $isShowingDetailView) {
                    EmptyView()
                }.hidden()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                dataStore.currentRegion.send(region)
                isShowingDetailView = true
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
        }
}

struct RegionList_Previews: PreviewProvider {
    static var previews: some View {
        RegionList()
    }
}


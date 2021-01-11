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
    let lib: WineRegion
    @EnvironmentObject var dataStore: DataStore

    var regionsResults: [RegionJson] {
        dataStore.filteredRegionTree
    }

    var body: some View {
        SearchBar(placeholder: "Search", searchEntry: $dataStore.regionFilter.filterString)
            .padding()
        List(regionsResults, children: \.children) { item in
            RegionRow(region: item, title: item.title, dataStore: dataStore)
        }
    }
}

struct RegionRow: View {
    @EnvironmentObject var lib: WineRegion
    @EnvironmentObject var wineMapView: WineMapView
    let region: RegionJson
    let title: String
    @State private var isShowingDetailView = false
    let dataStore: WineRegionProviding
    var body: some View {
            HStack {
                Text(region.title.capitalized).font(.title3)
                Spacer()
                NavigationLink(destination: ContentView(wineMapView: wineMapView,
                                                        viewModel: lib),
                               isActive: $isShowingDetailView) {
                    EmptyView()
                }.hidden()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                lib.loadMap(for: region)
                isShowingDetailView = true
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
        }
}

struct RegionList_Previews: PreviewProvider {
    static var previews: some View {
        RegionList(lib: WineRegion())
    }
}


//
//  TestContent.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 1/23/21.
//

import SwiftUI
import WineRegionLib

struct ExtensionRegionList: View {
    @ObservedObject var dataStore: DataStore

    var regionsResults: [RegionJson] {
        dataStore.regionTree
    }

    var body: some View {
        Text("Select a region to which you would like to add a sub region")
//        SearchBar(placeholder: "Search", searchEntry: $dataStore.regionFilter.filterString)
//            .padding()
        List(dataStore.regionTree, children: \.children) { item in
            Text(item.title)
        }
    }
}

struct TestContent_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionRegionList(dataStore: DataStore())
    }
}

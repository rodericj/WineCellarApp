//
//  TestContent.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 1/23/21.
//

import SwiftUI
import WineRegionLib

fileprivate extension DataStore {
    func create(region: SubregionCreation.NewRegion) {
        subregionCreation.newRegion = region
    }
}

struct NewRegionData {
    let title: String
    let geoJson: Data
}

struct ExtensionRegionList: View {
    @ObservedObject var dataStore: DataStore
    let newRegion: NewRegionData
    
    var body: some View {
        Text("Select a region to which you would like to add \(newRegion.title)")
            .font(.headline)
            .padding()
        List(dataStore.regionTree, children: \.children) { item in
            HStack {
                Text(item.title)
                Spacer()
                Button("+") {
                    dataStore.create(region: .init(title: newRegion.title,
                                                   parentRegion: item.id,
                                                   geoJsonData: newRegion.geoJson))
                }
            }
        }
    }
}

struct TestContent_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionRegionList(dataStore: DataStore(), newRegion: .init(title: "test", geoJson: Data()))
    }
}

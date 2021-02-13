//
//  ContentView.swift
//  WineRegionEditor
//
//  Created by Roderic Campbell on 2/11/21.
//

import SwiftUI
import WineRegionLib
import Combine

extension RegionJson {
    static func flatten(current: inout [RegionJson], thisItem: RegionJson) {
        current.append(thisItem)
        
        thisItem.children?.forEach { child in
            flatten(current: &current, thisItem: child)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    var regions: [RegionJson] {
        dataStore.regionTree
    }
    private var flatList: [RegionJson] {
        var currentList: [RegionJson] = []
        regions.forEach { singleItemWithChildren in
            RegionJson.flatten(current: &currentList, thisItem: singleItemWithChildren)
        }
        return currentList
    }
    
    private func drop(onto parentRegion: RegionJson, providers: [NSItemProvider]) -> Bool {
        providers.forEach { itemProvider in
            print("passed filter \(itemProvider)")
            _ = itemProvider.loadObject(ofClass: NSString.self) { regionID, _ in
                if let regionID = regionID as? String,
                   let regionUUID = UUID(uuidString: regionID) {
                    print("my object \(regionID)")
                    print("to this object \(regionID)")
                    dataStore.moveRegion(child: regionUUID, parent: parentRegion)
                }
            }
        }
        return true
    }
    var body: some View {
        ScrollView {
            VStack {
                ForEach (flatList) { region in
                    HStack {
                        Text(region.title)
                            .onDrag { NSItemProvider(object: region.id.uuidString as NSString) }
                            .onDrop(of: [.text], isTargeted: nil, perform: { providers -> Bool in
                                drop(onto: region, providers: providers)
                            })
                            .padding()
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(DataStore())
    }
}

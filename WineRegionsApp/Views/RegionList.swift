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

class WineTreeWrapper: ObservableObject {
    @Published var tree: [RegionJson] = []
}

struct RegionList: View {
    let lib: WineRegion
    @EnvironmentObject var treeWrapper: WineTreeWrapper
    var body: some View {
        List(treeWrapper.tree, children: \.children){ item in
            HStack{
                RegionRow(region: item, title: item.title)
            }
        }
    }
}

struct RegionRow: View {
    @EnvironmentObject var lib: WineRegion
    let region: RegionJson
    let title: String
    var body: some View {

        Button(action: {
            lib.loadMap(for: region)
        }) {
            HStack {
                Text(region.title).font(.title3)
                Spacer()
            }.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
        }
    }
}

struct RegionList_Previews: PreviewProvider {
    static var previews: some View {
        RegionList(lib: WineRegion())
    }
}


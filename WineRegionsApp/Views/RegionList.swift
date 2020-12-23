//
//  RegionList.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/13/20.
//

import SwiftUI
import WineRegionLib

struct RegionSection {
    let title: String
    let regions: [AppelationDescribable]
    
    func filtered(string: String) -> [AppelationDescribable]{
        print(regions)
        if string.isEmpty {
            return regions
        }
        return regions.filter { $0.description.uppercased().contains(string.uppercased()) }
    }
}


struct MakeView: View {
    let make: () -> AnyView
    var body: some View {
        make()
    }
}

struct RegionList: View {
    let lib: WineRegion
    var body: some View {
        MakeView {
            switch lib.regionsTree {
            case .regions(let regions):

                return AnyView(List(regions, children: \.children){ item in
                    HStack{
                        RegionRow(lib: lib, region: item, title: item.title)
                    }
                })
            default:
                return AnyView(Text("Loading"))
            }
        }
    }
}

struct RegionRow: View {
    let lib: WineRegionLib.WineRegion
    
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


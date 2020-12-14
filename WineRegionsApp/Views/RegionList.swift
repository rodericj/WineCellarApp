//
//  RegionList.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/13/20.
//

import SwiftUI
import WineRegionLib

struct RegionList: View {
    let allRegions = Italy.Tuscany.Appelation.allCases
    @State var searchText: String = ""

    var regions: [AppelationDescribable] {
        if searchText.isEmpty {
            return allRegions
        }
        return allRegions.filter { $0.description.contains(searchText) }
    }

    let lib: WineRegionLib.WineRegion

    var body: some View {
        ScrollView {
            SearchBar(placeholder: "Search", text: $searchText)
                .padding()
            LazyVStack(content: {
                ForEach(regions, id: \.description) { region in
                    Button(action: {
                        lib.getRegions(regions: [region])
                    }) {
                        HStack {
                            Text(region.description)
                                .font(.title2)
                            Spacer()
                        }.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
                    }
                }
            })
        }
    }
}

struct RegionList_Previews: PreviewProvider {
    static var previews: some View {
        RegionList(lib: WineRegion())
    }
}

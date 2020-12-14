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

struct RegionList: View {
    let sections = [
        RegionSection(title: "California 🇺🇸", regions: USA.California.Appelation.allCases),
        RegionSection(title: "Italy 🇮🇹", regions: Italy.Tuscany.Appelation.allCases),
        RegionSection(title: "France 🇫🇷", regions: France.Bordeaux.Appelation.allCases)
    ]
    @State var searchText: String = ""


    var filteredSection: [RegionSection] {
        if searchText.isEmpty {
            return sections
        }
        return sections.filter { section -> Bool in
            section.regions.filter { describable -> Bool in
                describable.description.uppercased().contains(searchText.uppercased())
            }.count > 0
        }
    }

    let lib: WineRegionLib.WineRegion

    var body: some View {
        ScrollView {
            SearchBar(placeholder: "Search", text: $searchText)
                .padding()
            LazyVStack(content: {
                ForEach(filteredSection, id: \.title) { section in
                    HStack {
                        Text(section.title).font(.title)
                        Spacer()
                    }.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
                    ForEach(section.filtered(string: searchText), id: \.description) { region in
                        RegionRow(lib: lib, region: region)
                    }
                }
            })
        }
    }
}

struct RegionRow: View {
    let lib: WineRegionLib.WineRegion

    let region: AppelationDescribable
    var body: some View {
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
}

struct RegionList_Previews: PreviewProvider {
    static var previews: some View {
        RegionList(lib: WineRegion())
    }
}


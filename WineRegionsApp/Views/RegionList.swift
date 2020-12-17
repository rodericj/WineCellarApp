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

struct NewRegionLineItem: Identifiable {
    var id = UUID()
    var name: String
    var children : [NewRegionLineItem]?
    var describable: AppelationDescribable?
}

extension France.Bordeaux {
    static var asNewRegionLineItems: [NewRegionLineItem] {
        Appelation.allCases.map { appelation in
            NewRegionLineItem(name: appelation.description, children: nil, describable: appelation)
        }
    }
}

extension USA.California {
    static var asNewRegionLineItems: [NewRegionLineItem] {

        return [
            NewRegionLineItem(name: "Napa",
                              children: Napa.Appelation.allCases.map { appelation in
                                NewRegionLineItem(name: appelation.description, children: nil, describable: appelation)
                              }),
            NewRegionLineItem(name: "Sonoma",
                              children: Sonoma.Appelation.allCases.map { appelation in
                                NewRegionLineItem(name: appelation.description, children: nil, describable: appelation)
                              }),
            NewRegionLineItem(name: "Central Coast",
                              children: CentralCoast.Appelation.allCases.map { appelation in
                                NewRegionLineItem(name: appelation.description, children: nil, describable: appelation)
                              })
        ]
    }
}

extension Italy.Tuscany {
    static var asNewRegionLineItems: [NewRegionLineItem] {
        Appelation.allCases.map { appelation in
            NewRegionLineItem(name: appelation.description, children: nil, describable: appelation)
        }
    }
}



struct RegionList: View {
    let newRegionSections = [
        NewRegionLineItem(name: "California 🇺🇸",
                          children: USA.California.asNewRegionLineItems),
        NewRegionLineItem(name: "Italy 🇮🇹",
                          children: Italy.Tuscany.asNewRegionLineItems),
        NewRegionLineItem(name: "France 🇫🇷",
                          children: France.Bordeaux.asNewRegionLineItems)
    ]

    let lib: WineRegionLib.WineRegion

    var body: some View {
        List(newRegionSections, children: \.children){
            item in
            HStack{
                RegionRow(lib: lib, region: item.describable, title: item.name)
            }
        }
    }
}

struct RegionRow: View {
    let lib: WineRegionLib.WineRegion

    let region: AppelationDescribable?
    let title: String
    var body: some View {

        if region != nil {
                Button(action: {
                    lib.getRegions(regions: [region!])
                }) {
                    HStack {
                        Text(region!.description)
                            .font(.title2)
                        Spacer()
                    }.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8))
                }
        } else {
            Text(title)
                .font(.title)
        }
    }
}

struct RegionList_Previews: PreviewProvider {
    static var previews: some View {
        RegionList(lib: WineRegion())
    }
}


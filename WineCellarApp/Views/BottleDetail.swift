//
//  BottleDetail.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar
import MapKit
import WineRegionLib
extension Bottle {
    var searchQuery: String {
        [country, region, subRegion].filter { $0 != "Unknown" } .joined(separator: " ")
    }
}
struct BottleDetail: View {
    let bottle: Bottle?
    let wineMapView: WineMapView

    var body: some View {
        VStack (alignment: .leading) {
            MapView(mapView: wineMapView)
                .onAppear(perform: {
                    if let region = bottle?.libAppelation {
                        wineMapView.showAppelationRegions([region])
                    }
            })
            if bottle != nil {
                BottleTextContent(bottle: bottle!)
                    .padding()
            }
        }
    }
}

struct BottleDetail_Previews: PreviewProvider {
    static let first = Bottle(wineID: "123", title: "Domain Sylvain Langoureau Saint Aubin 1er Cru En Remilly", location: "The cellar", price: 123.4, vintage: "2018", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")

    static var previews: some View {
        BottleDetail(bottle: first, wineMapView: WineMapView(wineRegionLib: WineRegionLib.WineRegion()))
    }
}

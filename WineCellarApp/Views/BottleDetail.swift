//
//  BottleDetail.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar
import MapKit

extension Bottle {
    var searchQuery: String {
        [country, region, subRegion].filter { $0 != "Unknown" } .joined(separator: " ")
    }
}
struct BottleDetail: View {
    let bottle: Bottle
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        VStack (alignment: .center) {
            Map(coordinateRegion: $region)
            BottleTextContent(bottle: bottle).padding()
        }.onAppear(perform: {
           performSearch()
        })
    }
}

extension BottleDetail {
    func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = bottle.searchQuery
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                print(error)
            } else if let response = response {
                region = response.boundingRegion
                print(response.boundingRegion)
            }
        }
    }
}

struct BottleDetail_Previews: PreviewProvider {
    static let first = Bottle(wineID: "123", title: "Domain Sylvain Langoureau Saint Aubin 1er Cru En Remilly", location: "The cellar", price: 123.4, vintage: "2018", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")

    static var previews: some View {
        BottleDetail(bottle: first)
    }
}

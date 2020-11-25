//
//  BottleDetail.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar
import MapKit

struct BottleDetail: View {
    let bottle: Bottle
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        VStack (alignment: .center) {
            Map(coordinateRegion: $region)
            VStack (alignment: .leading) {
                Text("\(bottle.vintage) \(bottle.title) ")
                    .bold()
                    .font(.body)
                    .foregroundColor(.blue) +
                    Text(bottle.varietal)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if bottle.ct != nil {
                    Text("CT\(String(format: "%.2f", bottle.ct!))")
                }
                if bottle.beginConsume != nil && bottle.endConsume != nil {
                    Text("Drink \(String(bottle.beginConsume!))-\(String(bottle.endConsume!))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Text("\(bottle.quantity) bottle (\(bottle.size)) - v $\(String(format: "%.2f", bottle.valuation))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(String(bottle.location)): (\(bottle.quantity))")
                    .font(.footnote)
                    .foregroundColor(.gray)

            }
            Spacer()
        }
    }
}

struct BottleDetail_Previews: PreviewProvider {
    static let first = Bottle(wineID: "123", title: "Fancy Bottle 1", location: "The cellar", price: 123.4, vintage: "2018", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")

    static var previews: some View {
        BottleDetail(bottle: first)
    }
}

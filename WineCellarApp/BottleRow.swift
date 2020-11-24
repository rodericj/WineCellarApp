//
//  BottleRow.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar

extension Bottle {
    var image: Image {
        switch self.type {

        case .red:
            return Image("Red")
        case .white:
            return Image("White")
        case .whiteSweetDessert:
            return Image("White")
        }
    }
}
struct BottleRow: View {
    let bottle: Bottle
    var body: some View {
        HStack (alignment: .top) {
            bottle.image
                .resizable()
                .frame(width: 17, height: 27)
                .padding()
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

struct BottleRow_Previews: PreviewProvider {
    static let first: Bottle =  {
        var bottle = Bottle(wineID: "123", title: "Fancy Bottle 1", location: "The cellar", price: 123.4, vintage: "2018", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")
        bottle.beginConsume = 2012
        bottle.endConsume = 2020
        bottle.ct = "CT92.4"
        return bottle
    }()

    static let second = Bottle(wineID: "31", title: "Fancy Bottle 2", location: "The cellar", price: 123.4, vintage: "2016", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")

    static var previews: some View {
        BottleRow(bottle: first)
    }
}

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
            bottle.image.resizable().frame(width: 17, height: 27).padding()
            BottleTextContent(bottle: bottle)
            Spacer()
        }
    }
}

extension Bottle {
    static let first: Bottle =  {
        var bottle = Bottle(wineID: "123", title: "Fancy Bottle 1", location: "The cellar", price: 123.4, vintage: "2018", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")
        bottle.beginConsume = 2012
        bottle.endConsume = 2020
        bottle.ct = "CT92.4"
        return bottle
    }()

    static let second = Bottle(wineID: "31", title: "Fancy Bottle 2", location: "The cellar", price: 123.4, vintage: "2016", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")

}
struct BottleRow_Previews: PreviewProvider {
    static var previews: some View {
        BottleRow(bottle: .first)
    }
}

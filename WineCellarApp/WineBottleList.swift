//
//  WineBottleList.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar

struct WineBottleList: View {
    @ObservedObject var cellar: WineCellar

    var body: some View {
        
        List(cellar.bottles, id: \.wineID) { bottle in
            BottleRow(bottle: bottle)
        }
    }
}

let coolCellar: WineCellar = {
    let cellar = WineCellar()
    cellar.bottles = [WineBottleList_Previews.first, WineBottleList_Previews.second]
    return cellar
}()

struct WineBottleList_Previews: PreviewProvider {
    static let first = Bottle(wineID: "123", title: "Fancy Bottle 1", location: "The cellar", price: 123.4, vintage: "2018", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")
    static let second = Bottle(wineID: "31", title: "Fancy Bottle 2", location: "The cellar", price: 123.4, vintage: "2016", quantity: 1, wineBarcode: "101010", size: "750ml", valuation: 123.4, currency: "USD", locale: "what is locale", country: "France", region: "Burgundy", subRegion: "Fancy Burgundy", appellation: "fanciest appellation", producer: "Jean Luke", sortProducer: "Producer", type: .red, varietal: "Pinot Noir", masterVarietal: "Master Pinot Noir", designation: "Designation", vineyard: "Left Vineyard")
    static var previews: some View {
        WineBottleList(cellar: coolCellar)
    }
}

//
//  WineBottleList.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar

struct WineBottleList: View {
    @EnvironmentObject var cellar: WineCellar

    var body: some View {
        NavigationView {
            List(cellar.bottles, id: \.wineID) { bottle in
                NavigationLink(destination: BottleDetail(bottle: bottle)
                                .navigationBarTitle("", displayMode: .inline)) {
                    BottleRow(bottle: bottle)
                }
            }.navigationBarTitle(Text("Bottles"))
        }
    }
}

let coolCellar: WineCellar = {
    let cellar = WineCellar()
    cellar.bottles = [.first, .second]
    return cellar
}()

struct WineBottleList_Previews: PreviewProvider {

    static let cellar: WineCellar = {
        let cellar = WineCellar()
        cellar.bottles = [.first, .second]
        return cellar
    }()

    static var previews: some View {
        WineBottleList().environmentObject(cellar)
    }
}

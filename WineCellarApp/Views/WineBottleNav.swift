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
        ScrollView {
            LazyVStack(content: {
                ForEach(cellar.bottles, id: \.wineID) { bottle in
                    NavigationLink(destination: BottleDetail(bottle: bottle)
                                    .navigationBarTitle("", displayMode: .inline)) {
                        BottleRow(bottle: bottle).padding(.bottom, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
                }
            })
        }
    }
}
struct WineBottleNavButtons: View {
    @EnvironmentObject var cellar: WineCellar
    var body: some View {
        HStack {
            Button(action: {
                cellar.refresh()
            }) {
                Image(systemName: "arrow.clockwise")
            }
            Button(action: {
                cellar.logout()
            }) {
                Image(systemName: "square.and.arrow.down")
                    .accentColor(.red)
                    .rotationEffect(.init(degrees: 270))
            }
        }
    }
}

struct WineBottleNav: View {
    var body: some View {
        NavigationView {
            WineBottleList()
            .navigationBarTitle(Text("Bottles"))
            .navigationBarItems(trailing: WineBottleNavButtons() )
        }
    }
}

struct WineBottleList_Previews: PreviewProvider {

    static let cellar: WineCellar = {
        let cellar = WineCellar()
        cellar.bottles = [.first, .second]
        return cellar
    }()

    static var previews: some View {
        WineBottleNav().environmentObject(cellar)
    }
}

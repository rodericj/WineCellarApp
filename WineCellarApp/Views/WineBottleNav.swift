//
//  WineBottleList.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar
import WineRegionLib
struct WineBottleList: View {
    @EnvironmentObject var cellar: WineCellar
    let wineMapView: WineMapView
    @State var searchText: String = ""
    var bottles: [Bottle] {
        if searchText.isEmpty {
            return cellar.bottles
        }
        return cellar.bottles.filter { $0.filter(on: searchText) }
    }

    var body: some View {
        VStack {
            ScrollView {
                SearchBar(placeholder: "Search", text: $searchText)
                    .padding()
                LazyVStack(content: {
                    ForEach(bottles, id: \.wineID) { bottle in
                        NavigationLink(destination: BottleDetail(bottle: bottle,
                                                                 wineMapView: wineMapView)
                                        .navigationBarTitle("", displayMode: .inline)) {
                            BottleRow(bottle: bottle).padding(.bottom, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        }
                    }
                })
            }
        }
    }
}
struct WineBottleNavButtons: View {
    @EnvironmentObject var cellar: WineCellar
    var body: some View {
        HStack {
            Button(action: {
                cellar.refresh(forceRefresh: true)
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
    let wineMapView = WineMapView(wineRegionLib: WineRegionLib.WineRegion()) // TODO this seems like an awkward way to initiate this
    var body: some View {
        NavigationView {
            WineBottleList(wineMapView: wineMapView)
            .navigationBarTitle(Text("Cellar"))
            .navigationBarItems(trailing: WineBottleNavButtons() )
                .navigationViewStyle(StackNavigationViewStyle())

            // Detail view
            BottleDetail(bottle: nil, wineMapView: wineMapView)
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

//
//  WineBottleList.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar

extension Bottle {
    func filter(on searchText: String) -> Bool {
        appellation.contains(searchText) ||
            country.contains(searchText) ||
            description.contains(searchText) ||
            designation.contains(searchText) ||
            locale.contains(searchText) ||
            location.contains(searchText) ||
            masterVarietal.contains(searchText) ||
            String(price).contains(searchText) ||
            producer.contains(searchText) ||
            region.contains(searchText) ||
            sortProducer.contains(searchText) ||
            subRegion.contains(searchText) ||
            title.contains(searchText) ||
            type.rawValue.contains(searchText) ||
            varietal.contains(searchText) ||
            vineyard.contains(searchText) ||
            vintage.contains(searchText)
    }
}
struct WineBottleList: View {
    @EnvironmentObject var cellar: WineCellar

    @State var searchText: String = ""
    let mapData = MapData()
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
                        NavigationLink(destination: BottleDetail(bottle: bottle, mapData: mapData)
                                        .navigationBarTitle("", displayMode: .inline)) {
                            BottleRow(bottle: bottle).padding(.bottom, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        }
                    }
                })
            }
        }.onAppear(perform: {
            mapData.fetchMaps()
        })
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

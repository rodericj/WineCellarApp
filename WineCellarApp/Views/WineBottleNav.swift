//
//  WineBottleList.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar
import WineRegionLib
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

extension Bottle {

    private func usaRegion() -> AppelationDescribable? {
        switch region {
        case WineCountry.USA.California.title:
            return WineCountry.USA.California.Appelation(rawValue: appellation)
        default:
            return nil
        }
    }
    private func frenchRegion() -> AppelationDescribable? {
        switch region {
        case WineCountry.France.Bordeaux.title:
            return WineCountry.France.Bordeaux.Medoc.Appelation(rawValue: appellation)
        case WineCountry.France.Burgundy.title:
            print("Burgundy region is not yet understood")
            return nil
        default:
            return nil
        }
    }
    var libAppelation: AppelationDescribable? {
        switch country {
        case WineCountry.France.title:
            return frenchRegion()
        case WineCountry.USA.title:
            return usaRegion()
        default:
            return nil
        }
    }
}
extension Bottle {
    private func bordeauxSubRegion() -> WineRegionDescribable? {
        let ret = BordeauxSubRegion(rawValue: subRegion)
        return ret
    }
    private func burgundySubRegion() -> WineRegionDescribable? { // TODO make this burgundy
        BordeauxSubRegion(rawValue: subRegion)
    }

    private func frenchRegion() -> WineRegionDescribable? {
        switch region {
        case "Bordeaux":
            let bordeaux = bordeauxSubRegion()
            print(bordeaux)
            return bordeaux
        case "Burgundy":
            return burgundySubRegion() // TODO this always returns bordeaux for now
        default:
            return nil
        }
    }
    var libRegion: WineRegionDescribable? {
        switch country {
        case "France":
            return frenchRegion()
        default:
            return nil
        }
    }
}

struct WineBottleList: View {
    @EnvironmentObject var cellar: WineCellar
    let wineRegion = WineRegion()
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
                        NavigationLink(destination: BottleDetail(bottle: bottle)
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

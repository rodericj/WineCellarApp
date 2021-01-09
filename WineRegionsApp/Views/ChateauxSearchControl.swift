//
//  SearchControl.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 1/5/21.
//

import SwiftUI
import Combine

struct ChateauxSearchControl: View {
    @State var isShowingSearch = false
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if isShowingSearch {
                    SearchBar(placeholder: "Search for Chateaux")
                }
                Button(action: {
                    isShowingSearch.toggle()
                }) {
                    Image(systemName: "magnifyingglass.circle")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .accentColor(.primary)
                .padding()
            }
        }
    }
}

struct SearchControl_Previews: PreviewProvider {
    static var previews: some View {
        ChateauxSearchControl()
    }
}

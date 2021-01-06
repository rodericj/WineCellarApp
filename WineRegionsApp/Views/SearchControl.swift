//
//  SearchControl.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 1/5/21.
//

import SwiftUI

struct SearchControl: View {
    @State var isShowingSearch = false
    @State var searchText = ""
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if isShowingSearch {
                    SearchBar(placeholder: "Search for Chateaux", text: $searchText)
                        .padding()
                }
                Button(action: {
                    print("Button was tapped")
                    isShowingSearch.toggle()
                }) {
                    Image(systemName: "magnifyingglass.circle")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                }
                .accentColor(.primary)
                .padding()
            }
            Spacer()
        }
    }
}

struct SearchControl_Previews: PreviewProvider {
    static var previews: some View {
        SearchControl()
    }
}

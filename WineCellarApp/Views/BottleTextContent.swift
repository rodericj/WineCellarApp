//
//  BottleTextContent.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar

struct BottleTextContent: View {
    let bottle: Bottle

    var body: some View {
        VStack (alignment: .leading) {
            Text("\(bottle.vintage) \(bottle.title) ")
                .bold()
                .font(.body)
                .foregroundColor(.blue) +
                Text(bottle.varietal)
                .font(.subheadline)
                .foregroundColor(.gray)

            if bottle.ct != nil {
                Text("CT\(String(format: "%2.1f", Float(bottle.ct!)!))")
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
    }
}

struct BottleTextContent_Previews: PreviewProvider {
    static var previews: some View {
        BottleTextContent(bottle: .first)
    }
}

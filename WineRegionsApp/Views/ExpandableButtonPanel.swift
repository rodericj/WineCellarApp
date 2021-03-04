//
//  ExpandableButtonPanel.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/14/20.
//

import SwiftUI

struct MapSelectionControl: View {
    @Binding var selectedMapType: WineMapType
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ExpandableButtonPanel(primaryItem: $selectedMapType,
                                      secondaryItems: [
                                        .MapBox(.satellite(.realistic)),
                                        .MapBox(.satellite(.doubled)),
                                        .MapBox(.satellite(.quadrupled)),
                                        .MapBox(.topo(.realistic)),
                                        .MapBox(.topo(.doubled)),
                                        .MapBox(.topo(.quadrupled)),
                                        .MapBox(.hillShader(.realistic)),
                                        .MapBox(.hillShader(.doubled)),
                                        .MapBox(.hillShader(.quadrupled))
                                      ])
                    .padding()

            }
        }
    }
}

extension WineMapType {
    var image: Image {
        switch self {
        case .MapBox:
            return Image("OpenStreetMap")
        case .MapKit:
            return Image("NormalMap")
        }
    }
}

struct ExpandableButtonPanel: View {

    @Binding var primaryItem: WineMapType
    @State var secondaryItems: [WineMapType]

    private let noop: () -> Void = {}
    private let size: CGFloat = 50
    private var cornerRadius: CGFloat {
        get { size / 2 }
    }
    private let shadowColor = Color.black.opacity(0.4)
    private let shadowPosition: (x: CGFloat, y: CGFloat) = (x: 2, y: 5)
    private let shadowRadius: CGFloat = 5

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ForEach(secondaryItems) { item in
                Button(action: { withAnimation {
                    self.isExpanded.toggle()
                    primaryItem = item
                }
                self.primaryItem.action()
                }) {
                    item.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: self.isExpanded ? self.size : 0,
                       height: self.isExpanded ? self.size : 0)
                .cornerRadius(cornerRadius)
            }
            
            if self.isExpanded  {
                Button(action: {
                    withAnimation {
                        self.isExpanded.toggle()
                    }
                    self.primaryItem.action()
                }) {
                    VStack {
                        Image(systemName: "map.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                    .frame(width: size, height: size)
                }
            } else {
                Button(action: {
                    withAnimation {
                        self.isExpanded.toggle()
                    }
                    self.primaryItem.action()
                }) {
                    VStack {
                        Image(systemName: "map")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                    .frame(width: size, height: size)

                }
            }
        }

        .shadow(
            color: shadowColor,
            radius: shadowRadius,
            x: shadowPosition.x,
            y: shadowPosition.y
        )
    }
}

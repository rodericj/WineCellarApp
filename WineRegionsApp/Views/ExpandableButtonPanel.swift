//
//  ExpandableButtonPanel.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/14/20.
//

import SwiftUI

struct MapSelectionControl: View {
    @Binding var selectedMapType: MapTypeSelection
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ExpandableButtonPanel(primaryItem: $selectedMapType,
                                      secondaryItems: [.sat, .topo, .normal])
                    .padding()

            }
        }
    }
}

//import MapKit
//enum WineMapType {
//    enum MapBoxType {
//        case shadows
//        case bigMountains
//        case colorful
//    }
//    case MapKit(MKMapType)
//    case MapBox(MapBoxType)
//}

struct MapTypeSelection: Identifiable { // TODO potentially call this an enum with 2 types:
    
    static let sat = MapTypeSelection(title: "satelite", image: Image("SateliteMap"))
    static let topo = MapTypeSelection(title: "topo", image: Image("OpenStreetMap"))
    static let normal = MapTypeSelection(title: "normal", image: Image("NormalMap"))
    var id: UUID = UUID()
    let title: String
    let image: Image
    private(set) var action: (() -> Void)? = nil
}

struct ExpandableButtonPanel: View {

    @Binding var primaryItem: MapTypeSelection
    @State var secondaryItems: [MapTypeSelection]

    private let noop: () -> Void = {}
    private let size: CGFloat = 70
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
                self.primaryItem.action?()
                }) {
                    item.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .frame(width: self.isExpanded ? self.size : 0,
                       height: self.isExpanded ? self.size : 0)
                .cornerRadius(cornerRadius)
            }

            // The current button
            Button(action: { withAnimation {
                self.isExpanded.toggle()
            }
            self.primaryItem.action?()
            }) {
                if self.isExpanded  {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: size / 2, height: size / 2)

                } else {
                    self.primaryItem.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .cornerRadius(cornerRadius)
                }
            }
            .padding(2)
            .background(Color.white)
            .cornerRadius(cornerRadius)
        }

        .shadow(
            color: shadowColor,
            radius: shadowRadius,
            x: shadowPosition.x,
            y: shadowPosition.y
        )
    }
}

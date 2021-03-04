//
//  ExpandableButtonPanel.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/14/20.
//

import SwiftUI


protocol HasImage: Identifiable {
    var image: Image { get }
}

extension MapboxMapView.MapStyle: HasImage {
    public var id: Int {
        switch self {
        case .topo:
            return 1
        case .hillShader:
            return 2
        case .satellite:
            return 3
        }
    }
    
    var image: Image {
        switch self {
        case .topo:
            return Image("OpenStreetMap")
        case .hillShader:
            return Image("OpenStreetMap")
        case .satellite:
            return Image("OpenStreetMap")
        }
    }
}


extension MapboxMapView.MapStyle.TerrainExaggeration: HasImage {
    public var id: Int {
        return rawValue
    }
    
    var image: Image {
        switch self {
        case .realistic:
            return Image("NormalMap")
        case .doubled:
            return Image("NormalMap")
        case .quadrupled:
            return Image("NormalMap")
        }
    }
}

struct MapSelectionControl: View {
    @Binding var selectedMapType: MapboxMapView.MapStyle
    @Binding var selectedMapExaggeration: MapboxMapView.MapStyle.TerrainExaggeration
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ExpandableButtonPanel(primaryItem: $selectedMapExaggeration,
                                      secondaryItems: [
                                        .realistic,
                                        .doubled,
                                        .quadrupled
                                      ],
                                      imageName: "map.fill")
                    .padding()

            }
            VStack {
                Spacer()
                ExpandableButtonPanel(primaryItem: $selectedMapType,
                                      secondaryItems: [
                                        .satellite(.realistic),
                                        .topo(.realistic),
                                        .hillShader(.realistic),
                                      ],
                                      imageName: "map")
                    .padding()

            }
        }
    }
}

fileprivate struct ButtonPanel: View {
    let size: CGFloat
    let imageName: String
    @Binding var isExpanded: Bool
    var body: some View {
        Button(action: {
            withAnimation {
                self.isExpanded.toggle()
            }
        }) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            .frame(width: size, height: size)
        }
    }
}
struct ExpandableButtonPanel<T: Identifiable & HasImage>: View {

    @Binding var primaryItem: T
    @State var secondaryItems: [T]
    let imageName: String
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
                ButtonPanel(size: size,
                            imageName: "\(imageName).fill",
                            isExpanded: $isExpanded)
            } else {
                ButtonPanel(size: size,
                            imageName: "\(imageName)",
                            isExpanded: $isExpanded)
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

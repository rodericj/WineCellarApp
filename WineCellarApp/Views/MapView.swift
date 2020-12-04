//
//  MapView.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/27/20.
//

import WineCellar
import MapKit
import SwiftUI
import WineRegionLib
import Combine

struct MapView: UIViewRepresentable {
    private let wineRegionLib = WineRegionLib.WineRegion()

    func showAppelationRegions(_ appelations: [AppelationDescribable]) {
        wineRegionLib.getRegionsStruct(regions: appelations)
        var cancellable: AnyCancellable? = wineRegionLib.$regionMaps.sink { _ in
            print("completed")
        } receiveValue: { mapMapping in
            let values = mapMapping.map { $0.value }
            print(values)
            add(features: values)
            var zoomRect:MKMapRect = .null
            mapView.overlays.forEach { overlay in
                zoomRect = zoomRect.union(overlay.boundingMapRect)
            }
            mapView.setVisibleMapRect(zoomRect, animated: true)
        }
    }
    func showLibRegion(_ regions: [WineRegionDescribable]) {
//        guard let regions = regions else { return }
        fatalError()
        wineRegionLib.getRegions(regions: regions)
        let cancellable = wineRegionLib.$regionMaps.sink { _ in
            print("completed")
            var zoomRect:MKMapRect = .null
            mapView.overlays.forEach { overlay in
                zoomRect = zoomRect.union(overlay.boundingMapRect)
            }
            mapView.setVisibleMapRect(zoomRect, animated: true)
        } receiveValue: { mapMapping in
            let values = mapMapping.map { $0.value }
            print(values)
            add(features: values)
        }

    }

    private func add(features: [MKGeoJSONFeature]) {
        features.forEach { feature in
            feature.geometry
                .map { $0 as? MKPolygon  }
                .compactMap { $0 }
                .forEach { multiPolygon in
                    print("polygon")
                    mapView.addOverlay(multiPolygon)
                }

            print("The feature \(feature.geometry)")
            feature.geometry
                .map { $0 as? MKMultiPolygon }
                .compactMap { $0 }
                .forEach { multiPolygon in
                    print("polygon")
                    multiPolygon.polygons.forEach {
                        print("polygon \($0)")
                        mapView.addOverlay($0)
                    }
                }
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        return mapView
    }
//    var data: MapData?

    let mapView = MKMapView()
    func updateUIView(_ mapView: MKMapView, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        let colors: [UIColor] = [.red, .yellow, .blue, .white, .purple, .green]
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKPolygon {
                let index = mapView.overlays.firstIndex { $0 === overlay } ?? 0
                let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
                renderer.fillColor = colors[index % colors.count].withAlphaComponent(0.3)
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

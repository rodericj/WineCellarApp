//
//  MapView.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/27/20.
//

import WineCellar
import MapKit
import SwiftUI

extension Bottle {
    var regionPostalCodes: WineRegionDescribable {
        switch region {
        case "Bordeaux":
            return WineRegion.France.bordeaux
        case "Burgundy":
            return WineRegion.France.burgundy
        case "Alsace":
            return WineRegion.France.rhône
        default:
            return WineRegion.France.bordeaux
        }
    }
}
struct MapView: UIViewRepresentable {
    func fetchRegions(for bottle: Bottle, data: MapData) {
        let polygons = data.regionPolygons(with: bottle.regionPostalCodes)
        mapView.addOverlays(polygons)

        // zoom to the union of all of the overlays
        guard let first = polygons.first else {
            debugPrint("no zips in this region")
            return
        }

        let mapRect = polygons.reduce(first.boundingMapRect) { (result, next) -> MKMapRect in
            result.union(next.boundingMapRect)
        }
        mapView.setVisibleMapRect(mapRect, animated: true)

    }
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        return mapView
    }

    let mapView = MKMapView()

    func updateUIView(_ mapView: MKMapView, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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
                print(mapView.overlays)
                print(overlay)
                let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
                renderer.fillColor = colors[index % mapView.overlays.count].withAlphaComponent(0.3)
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

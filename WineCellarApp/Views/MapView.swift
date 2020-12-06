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

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    private var finalRect: MKMapRect?

    private let padding: UIEdgeInsets = {
        let inset = UIScreen.main.bounds.size.width * 0.05
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }()

    init(_ parent: MapView) {
        self.parent = parent
    }

    // Handles the zooming out to a common rect, before zooming to the final destination
    func handleNewMapping(features: [MKGeoJSONFeature], mapView: WineMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.add(features: features)

        var mapRect: MKMapRect = .null
        mapView.overlays.forEach { overlay in
            mapRect = mapRect.union(overlay.boundingMapRect)
        }
        let finalMapRect = mapRect
        let mapRectOfAllNewOverlays = mapRect

        if (!mapRect.intersects(mapView.visibleMapRect)) {
            let unionmapRect = mapRect.union(mapView.visibleMapRect);
            if let coordinator = mapView.delegate as? Coordinator {
                coordinator.finalRect = finalMapRect
            }
            setMapRect(unionmapRect, on: mapView)
        } else {
            setMapRect(mapRectOfAllNewOverlays, on: mapView)
        }
    }

    private func setMapRect(_ rect: MKMapRect, on mapView: MKMapView ) {
        mapView.setVisibleMapRect(rect,
                                  edgePadding: padding,
                                  animated: true)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let finalRect = finalRect {
            self.finalRect = nil
            setMapRect(finalRect, on: mapView)
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.orange.withAlphaComponent(0.2)
            renderer.strokeColor = .orange
            renderer.lineWidth = 1
            return renderer
        }
        return MKOverlayRenderer()
    }
}

struct MapView: UIViewRepresentable {
    let mapView: MKMapView

    private let wineRegionLib = WineRegionLib.WineRegion()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

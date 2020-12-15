//
//  MapView.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/27/20.
//

import MapKit
import SwiftUI
import WineRegionLib
import Combine

extension MapTypeSelection {
    var mapType: MKMapType {
        switch self.title {
        case MapTypeSelection.normal.title:
            return .standard
        case MapTypeSelection.topo.title:
            return .standard
        case MapTypeSelection.sat.title:
            return .satellite
        default:
            return .standard
        }
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    let mapView: MKMapView
    private var finalRect: MKMapRect?
    let tileRenderer = MKTileOverlayRenderer(tileOverlay: OpenStreetMapTileOverlay())
    private let padding: UIEdgeInsets = {
        let inset = UIScreen.main.bounds.size.width * 0.05
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }()

    init(_ parent: MapView, mapView: MKMapView) {
        self.parent = parent
        self.mapView = mapView
    }

    var openStreetMapsRendererEnabled: Bool = false

    func updateMapType(selection: MapTypeSelection) {
        openStreetMapsRendererEnabled = selection.title == MapTypeSelection.topo.title
        mapView.mapType = selection.mapType

        // This seems to be required in order to get the renderers to reload
        let annotations = mapView.overlays
        mapView.removeOverlays(annotations)
        mapView.addOverlays(annotations)
    }

    private func smoothePanRegion(mapView: MKMapView) {
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
    func handleNewPolygons(_ polygons: [MKPolygon], mapView: WineMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlays(polygons)
        smoothePanRegion(mapView: mapView)
  }

    // Handles the zooming out to a common rect, before zooming to the final destination
    func handleNewMapping(features: [MapKitOverlayable], mapView: WineMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.add(features: features)
        smoothePanRegion(mapView: mapView)
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
    let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // use this tile renderer when the user selects it
        if openStreetMapsRendererEnabled {
            return tileRenderer
        }

        if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            let color = colors.randomElement()
            renderer.fillColor = color?.withAlphaComponent(0.2)
            renderer.strokeColor = color
            renderer.lineWidth = 1
            return renderer
        }
        return MKOverlayRenderer()
    }
}

struct MapView: UIViewRepresentable {
    let mapView: MKMapView
    @Binding var selectedMapType: MapTypeSelection

    private let wineRegionLib = WineRegionLib.WineRegion()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.updateMapType(selection: selectedMapType)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, mapView: mapView)
    }
}

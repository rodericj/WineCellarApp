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

extension MKMapItem: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D { placemark.coordinate }
    public var title: String? { name }
}

class Coordinator: NSObject, MKMapViewDelegate, ObservableObject {
    var parent: MapKitBasedMapView
    let mapView: MKMapView
    var dataStore: WineRegionProviding

    private var finalRect: MKMapRect?
    let tileRenderer = MKTileOverlayRenderer(tileOverlay: ExternalTileOverlay(source: .openstreetMap))
    private let padding: UIEdgeInsets = {
        let inset = UIScreen.main.bounds.size.width * 0.05
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }()

    init(_ parent: MapKitBasedMapView, mapView: MKMapView, dataStore: WineRegionProviding) {
        self.parent = parent
        self.mapView = mapView
        self.dataStore = dataStore
    }

    var openStreetMapsRendererEnabled: Bool = false

    func updateMapType(selection: MapTypeSelection) {
        openStreetMapsRendererEnabled = selection.title == MapTypeSelection.topo.title
        mapView.mapType = selection.mapType

        // A-ha, this is where we need to figure out the regions, maybe instead of getting the current overlays from a publisher somehow
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

    // i think this could work but really we want this coordinator to have access to the datastore, that's the real answer
    var currentMappings: [MapKitOverlayable] = []
    
    // Handles the zooming out to a common rect, before zooming to the final destination
    func handleNewMapping(features: [MapKitOverlayable], mapView: MKMapView) {
        currentMappings = features
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        print("adding a mapping in mapKit")
        mapView.add(features: features)
        smoothePanRegion(mapView: mapView)
    }

    private func setMapRect(_ rect: MKMapRect, on mapView: MKMapView ) {
        mapView.setVisibleMapRect(rect,
                                  edgePadding: padding,
                                  animated: true)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        dataStore.region = mapView.region
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = CGFloat(log2(zoomWidth)) - 9
        dataStore.mapZoom = zoomFactor
        
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

        if let overlay = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay)
            let color = colors[overlay.pointCount % colors.count]
            renderer.fillColor = color.withAlphaComponent(0.2)
            renderer.strokeColor = color
            renderer.lineWidth = 1
            return renderer
        }
        return MKOverlayRenderer()
    }
}

extension MKPolygon {
    func contains(mapPoint: MKMapPoint) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let polygonPoint = polygonRenderer.point(for: mapPoint)
        return polygonRenderer.path.contains(polygonPoint)
    }
}

struct MapKitBasedMapView: UIViewRepresentable {
    let mapView: MKMapView
    @Binding var selectedMapType: MapTypeSelection
    @EnvironmentObject var dataStore: DataStore

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        print("need to set the zoom and center coordinates")
        mapView.region = dataStore.region
        // TODO it seems as though the geojson does not persist between map type changes
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        print("We do however want to get the current overlay")
//        dataStore.
//        context.coordinator.updateMapType(selection: selectedMapType)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, mapView: mapView, dataStore: dataStore)
    }
}

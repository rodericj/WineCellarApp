//
//  WineMapview.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 12/5/20.
//

import Combine
import MapKit
import WineRegionLib
import SwiftUI

class WineMapView: MKMapView, ObservableObject {

    var cancellable: AnyCancellable? = nil
    let wineRegionLib: WineRegion
    var currentSearch: MKLocalSearch?

    public func showAppelationRegions(_ appelations: [AppelationDescribable]) {
        wineRegionLib.getRegions(regions: appelations)
    }
    
    public func add(features: [MapKitOverlayable]) {
        print("Features count: \(features.count)")
        features
            .compactMap { $0 as? MKPolygon }
            .forEach { polygon in
                self.addOverlay(polygon)
            }
        features
            .compactMap { $0 as? MKMultiPolygon }
            .forEach { multiPolygon in
                multiPolygon.polygons.forEach {
                    self.addOverlay($0)
                }
            }
        features
            .compactMap { $0 as? MKGeoJSONFeature }
            .forEach { feature in
            feature.geometry
                .map { $0 as? MKPolygon  }
                .compactMap { $0 }
                .forEach { polygon in
                    self.addOverlay(polygon)
                }

            feature
                .geometry
                .map { $0 as? MKMultiPolygon }
                .compactMap { $0 }
                .forEach { multiPolygon in
                    multiPolygon.polygons.forEach {
                        self.addOverlay($0)
                    }
                }
        }
    }

    init(wineRegionLib: WineRegion) {
        self.wineRegionLib = wineRegionLib
        super.init(frame: .zero)

        cancellable = wineRegionLib.$regionMaps
            .receive(on: DispatchQueue.main)
            .sink { _ in
            debugPrint("completed")
        } receiveValue: { mapMapping in
            switch mapMapping {

            case .regions(let mapMapping):
                self.handle(mapMapping: mapMapping)
            default:
                break

            }

        }
    }

    private func handle(mapMapping: [MapKitOverlayable]) {
        debugPrint("we got mappings \(mapMapping.count)")
        if mapMapping.isEmpty { return }
        (self.delegate as? Coordinator)?.handleNewMapping(features: mapMapping, mapView: self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func performLocalSearch(query: String? = nil) {
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.winery])
        if let query = query, !query.isEmpty {
            request.naturalLanguageQuery = query
        }
        removeAnnotations(annotations)
        request.region = region
        currentSearch = MKLocalSearch(request: request)
        currentSearch?.start { [weak self]  (response, error) in
            if let error = error {
                debugPrint("we got an error searching locally \(error)")
                return
            }
            if let response = response, let strongSelf = self {
                strongSelf.handleSearch(response: response)
            }
        }
    }

    private func handleSearch(response: MKLocalSearch.Response) {
        let currentOverlays = overlays
        let annotations = response
            .mapItems
            // Filter out the mapItems from the response that are not in the polygon we are showing
            .filter({ mapItem in
                currentOverlays
                    .compactMap { $0 as? MKPolygon }
                    .first { polygon in
                        polygon.contains(mapPoint: MKMapPoint(mapItem.placemark.coordinate))
                    } != nil
            })
        addAnnotations(annotations)
    }
}

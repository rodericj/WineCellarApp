//
//  WineMapview.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 12/5/20.
//

import Combine
import MapKit
import WineRegionLib

class WineMapView: MKMapView, ObservableObject {

    var cancellable: AnyCancellable? = nil
    let wineRegionLib: WineRegion

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

//            debugPrint("The feature \(feature.geometry)")
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
}

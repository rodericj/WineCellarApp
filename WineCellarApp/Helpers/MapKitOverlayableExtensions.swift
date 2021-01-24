//
//  MapKitOverlayableExtensions.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 1/23/21.
//

import MapKit
import WineRegionLib

public extension MKMapView {
    func add(features: [MapKitOverlayable]) {
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
}

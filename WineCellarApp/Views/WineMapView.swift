//
//  WineMapview.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 12/5/20.
//

import Combine
import MapKit
import WineRegionLib

class WineMapView: MKMapView {

    var cancellable: AnyCancellable? = nil
    var secondCancellable: AnyCancellable? = nil
    let wineRegionLib: WineRegion

    public func showAppelationRegions(_ appelations: [AppelationDescribable]) {
        wineRegionLib.getRegions(regions: appelations)
    }
    
    public func add(features: [MKGeoJSONFeature]) {
        features.forEach { feature in
            feature.geometry
                .map { $0 as? MKPolygon  }
                .compactMap { $0 }
                .forEach { multiPolygon in
                    debugPrint("polygon")
                    self.addOverlay(multiPolygon)
                }

            debugPrint("The feature \(feature.geometry)")
            feature.geometry
                .map { $0 as? MKMultiPolygon }
                .compactMap { $0 }
                .forEach { multiPolygon in
                    debugPrint("polygon")
                    multiPolygon.polygons.forEach {
                        debugPrint("polygon \($0)")
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
            let values = mapMapping.map { $0.value }
            if values.isEmpty { return }
            debugPrint(values)
            (self.delegate as? Coordinator)?.handleNewMapping(features: values, mapView: self)
        }

        secondCancellable = wineRegionLib.$regionPolygons
            .receive(on: DispatchQueue.main)
            .sink { _ in
            debugPrint("completed")
        } receiveValue: { mapMapping in
            let values = mapMapping.map { $0.value }
            if values.isEmpty { return }
            debugPrint(values)
            (self.delegate as? Coordinator)?.handleNewPolygons(values, mapView: self)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

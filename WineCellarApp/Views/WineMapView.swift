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
    var annotationsCancellable: AnyCancellable? = nil
    let dataStore: WineRegionProviding
    var currentSearch: MKLocalSearch?

    init(dataStore: WineRegionProviding) {
        self.dataStore = dataStore
        super.init(frame: .zero)

        cancellable = dataStore.wineRegionLib.$regionMaps
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

        // We need to observe changes on the data store at this point
        annotationsCancellable = dataStore.mapItemsPublisher.sink { mapItems in
            print("got map items \(mapItems.count)")
            self.removeAnnotations(self.annotations)
            let newAnnotations = mapItems.filter({ mapItem in
                self.overlays
                    .compactMap { $0 as? MKPolygon }
                    .first { polygon in
                        polygon.contains(mapPoint: MKMapPoint(mapItem.placemark.coordinate))
                    } != nil
            })
            self.addAnnotations(newAnnotations)
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

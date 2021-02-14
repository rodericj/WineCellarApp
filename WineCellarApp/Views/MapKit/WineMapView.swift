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

    var cancellables: [AnyCancellable] = []
    var annotationsCancellable: AnyCancellable? = nil
    let dataStore: WineRegionProviding
    var currentSearch: MKLocalSearch?

    init(dataStore: WineRegionProviding) {
        self.dataStore = dataStore
        super.init(frame: .zero)

        // and this is where we get the original map from 
        dataStore.wineRegionLib.$regionMaps
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
        }.store(in: &cancellables)

        // We need to observe changes on the data store at this point
        dataStore.mapItemsPublisher.sink { mapItems in
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
        }.store(in: &cancellables)
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

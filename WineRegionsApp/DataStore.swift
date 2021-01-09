//
//  DataStore.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 1/8/21.
//

import Combine
import Foundation
import MapKit
import WineRegionLib

class DataStore: ObservableObject {
    var searchCancellable: AnyCancellable? = nil
    var treeCancellable: AnyCancellable? = nil
    var mapsCancellable: AnyCancellable? = nil

    var chateauxSearch = ChateauxSearch()
    let wineRegionLib = WineRegion()

    var currentSearch: MKLocalSearch?

    @Published var regionTree: [RegionJson] = []
    @Published var regionTreeLoadingProgress: Float = 0
    @Published var mapItems: [MKMapItem] = []

    var region: MKCoordinateRegion = .init()

    init() {
        mapsCancellable = wineRegionLib.$regionMaps
            .receive(on: DispatchQueue.main)
            .sink { result in
            switch result {
            case .regions:
                self.regionTreeLoadingProgress = 0
            case .loading(let progress):
                self.regionTreeLoadingProgress = progress
                print("loading from scene delegate \(progress)")
            case .none:
                self.regionTreeLoadingProgress = 0
                print("no state for the tree")
            case let .error(error, string):
                self.regionTreeLoadingProgress = 0
                print("Error fetching regions tree, probably need to bubble this up \(error): \(string ?? "No error")")
            }
        }

        treeCancellable = wineRegionLib.$regionsTree
            .receive(on: DispatchQueue.main)
            .sink { result in
            switch result {
            case .regions(let tree):
                self.regionTree = tree.sorted { $0.title < $1.title }
                self.regionTreeLoadingProgress = 0
            case .loading(let progress):
                self.regionTreeLoadingProgress = progress
                print("loading from scene delegate \(progress)")
            case .none:
                self.regionTreeLoadingProgress = 0
                print("no state for the tree")
            case .error(let error, let string):
                self.regionTreeLoadingProgress = 0
                print("Error fetching regions tree, probably need to bubble this up \(error): \(string ?? "No Error")")
            }
        }

        searchCancellable = chateauxSearch.$searchString
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink { string in
                self.performLocalSearch(query: string)
            }
    }

    func performLocalSearch(query: String? = nil) {
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.winery])
        if let query = query, !query.isEmpty {
            request.naturalLanguageQuery = query
        }
        request.region = region
        currentSearch = MKLocalSearch(request: request)
        currentSearch?.start { [weak self]  (response, error) in
            if let error = error {
                debugPrint("we got an error searching locally in new method \(error)")
                return
            }
            if let response = response, let strongSelf = self {
                strongSelf.mapItems = response.mapItems
            }
        }
    }
}

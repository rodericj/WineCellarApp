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

class DataStore: ObservableObject, WineRegionProviding {
    var cancellables: [AnyCancellable] = []
    var chateauxSearch = ChateauxSearch()
    var regionFilter = RegionFilter()
    
    let wineRegionLib = WineRegion()
    var currentSearch: MKLocalSearch?
    
    var currentRegion: CurrentValueSubject<RegionJson?, Never> = .init(nil)
    var newRegionOSMID: CurrentValueSubject<String?, Never> = .init(nil)
    
    @Published var regionTree: [RegionJson] = []
    
    @Published var filteredRegionTree: [RegionJson] = []
    @Published var regionTreeLoadingProgress: Float = 0
    @Published var mapItems: [MKMapItem] = []
    var mapItemsPublisher: Published<[MKMapItem]>.Publisher { $mapItems }
    
    var region: MKCoordinateRegion = .init()
    
    init() {
//        filterCancellable = regionFilter.$filterString.combineLatest($regionTree)
//            .receive(on: DispatchQueue.main)
//            .sink { filterString, tree in
//                self.filteredRegionTree = self.regionTree.filter(searchString: filterString)
//                print(self.filteredRegionTree.count)
//            }

        wineRegionLib.$regionMaps
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
            }.store(in: &cancellables)
        
        wineRegionLib.$regionsTree
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .regions(let tree):
                    print("Got \(tree.count) items")
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
            }.store(in: &cancellables)
        
        chateauxSearch.$searchString
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink { string in
                self.performLocalSearch(query: string)
            }.store(in: &cancellables)
        
        currentRegion
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] region in
                print("current region: \(region.title)")
                self?.wineRegionLib.loadMap(for: region)
            }.store(in: &cancellables)
        
        // With the new osmID and a selected region,
        // 1. create a new region,
        // 2. then update with the selected region as the parent,
        // 3. finally update the tree
        newRegionOSMID
            .removeDuplicates()
            .compactMap { $0 }
            .combineLatest(currentRegion.compactMap { $0 })
            .eraseToAnyPublisher()
            .flatMap { newOSMID, currentRegion in
                self.wineRegionLib.createRegion(osmID: newOSMID, asChildTo: currentRegion)
            }.sink { completionValue in
                print("completionValue")
            } receiveValue: { regionJson in
                self.wineRegionLib.getRegionTree()
            }.store(in: &cancellables)
    }
    public func getRegionTree() {
        wineRegionLib.getRegionTree()
    }
    
    public func deleteSelectedRegion() {
        guard let unwrappedCurrentRegion = currentRegion.value else { return }
        wineRegionLib
            .delete(region: unwrappedCurrentRegion)
            .sink { [weak self] completionState in
                print(completionState)
                self?.regionTree.removeAll { testRegionJson -> Bool in
                    testRegionJson == unwrappedCurrentRegion
                }
                self?.currentRegion.send(nil)
            } receiveValue: { regionJson in
                print("regionJson")
            }.store(in: &cancellables)
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

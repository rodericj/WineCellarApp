//
//  DataStore.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 1/8/21.
//

import Combine
import Foundation
import WineRegionLib
import UIKit
import OSLog

class DataStore: ObservableObject, WineRegionProviding {
    var cancellables: [AnyCancellable] = []
    var chateauxSearch = ChateauxSearch()
    var regionFilter = RegionFilter()
    
    let wineRegionLib = WineRegion()
    
    var currentRegion: CurrentValueSubject<SelectedRegion, Never> = .init(.noneSelected)
    var queuedRegionUUID: CurrentValueSubject<UUID?, Never> = .init(nil)
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "RegionDataStore")

    var currentRegionNavTitle: String {
        var exaggerationString = ""
        switch selectedExaggerationLevel {
        
        case .realistic:
            exaggerationString = ""
        case .doubled:
            exaggerationString = "2x"
        }

        switch currentRegion.value {
        case .selected(let region):
            return region.title.appendingFormat(" %@", exaggerationString)
        case .noneSelected:
            return ""
        }
    }
    // Region List state
    var isLeafNodeRegion: Bool {
        switch currentRegion.value {
        case .selected(let region):
            return (region.children ?? []).isEmpty
        case .noneSelected:
            return false
        }
    }
    
    @Published var regionTree: [RegionJson] = []
//    @Published var filteredRegionTree: [RegionJson] = []
    @Published var regionTreeLoadingProgress: Float = 0
    
    // Map View State
    @Published var selectedMapType: MapboxMapView.MapStyle = .hillShader(.realistic)
    @Published var selectedExaggerationLevel: MapboxMapView.MapStyle.TerrainExaggeration = .realistic
    
    var mapZoom: CGFloat = 1.0
        
    init() {
//        filterCancellable = regionFilter.$filterString.combineLatest($regionTree)
//            .receive(on: DispatchQueue.main)
//            .sink { filterString, tree in
//                self.filteredRegionTree = self.regionTree.filter(searchString: filterString)
//                print(self.filteredRegionTree.count)
//            }
        logger.debug("Initialize dataStore")
        wineRegionLib.$regionMaps
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .regions:
                    self.regionTreeLoadingProgress = 0
                case .loading(let progress):
                    self.regionTreeLoadingProgress = progress
                    self.logger.debug("loading from scene delegate \(progress)")
                case .none:
                    self.regionTreeLoadingProgress = 0
                    self.logger.debug("no state for the tree")
                case let .error(error, string):
                    self.regionTreeLoadingProgress = 0
                    self.logger.error("Error fetching regions tree, probably need to bubble this up \(error as NSObject): \(string ?? "No error")")
                }
            }.store(in: &cancellables)
        
        wineRegionLib.$regionsTree
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .regions(let tree):
                    self?.regionTree = tree.sorted { $0.title < $1.title }
                    if let queuedUUID = self?.queuedRegionUUID.value {
                        self?.selectQueuedRegion(with: queuedUUID)
                    }
                    self?.regionTreeLoadingProgress = 0
                    self?.regionTree.storeInCoreSpotlight()
                case .loading(let progress):
                    self?.regionTreeLoadingProgress = progress
                    self?.logger.debug("loading from scene delegate \(progress)")
                case .none:
                    self?.regionTreeLoadingProgress = 0
                    self?.logger.debug("no state for the tree")
                case .error(let error, let string):
                    self?.regionTreeLoadingProgress = 0
                    self?.logger.error("Error fetching regions tree, probably need to bubble this up \(error as NSObject): \(string ?? "No Error")")
                }
            }.store(in: &cancellables)
        
//        chateauxSearch.$searchString
//            .debounce(for: 0.2, scheduler: DispatchQueue.main)
//            .sink { string in
//                self.performLocalSearch(query: string)
//            }.store(in: &cancellables)
        
        currentRegion
            .sink { [weak self] selectedRegion in
                switch selectedRegion {
                case .selected(let region):
                    self?.wineRegionLib.loadMap(for: region)
                case .noneSelected:
                    break
                }
            }.store(in: &cancellables)
    }
    public func getRegionTree() {
        wineRegionLib.getRegionTree()
    }
    
    public func deleteSelectedRegion() {
        guard case let .selected(region) = currentRegion.value else {
            print("no region selected, nothing to delete")
            return
        }
        wineRegionLib
            .delete(region: region)
            .sink { [weak self] completionState in
                self?.wineRegionLib.getRegionTree()
                self?.currentRegion.send(.noneSelected)
            } receiveValue: { regionJson in
                print("regionJson")
            }.store(in: &cancellables)
    }
    
    private func selectQueuedRegion(with uuid: UUID) {
        let regionsWithThisUUID = self.regionTree.compactMap { regionJson in
            regionJson.findRegion(with: uuid)
        }
        if let matchingRegion = regionsWithThisUUID.first {
            self.currentRegion.send(.selected(matchingRegion))
        }
        self.queuedRegionUUID.send(nil)
    }
}

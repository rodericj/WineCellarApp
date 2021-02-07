//
//  DataStore.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 1/10/21.
//

import Foundation
import MapKit
import WineRegionLib
import Combine

class BottleDataStore: ObservableObject, WineRegionProviding {
    var currentRegion: CurrentValueSubject<SelectedRegion, Never> = .init(.noneSelected)
    
    var wineRegionLib: WineRegion = WineRegion()

    @Published var mapItems: [MKMapItem] = []
    var mapItemsPublisher: Published<[MKMapItem]>.Publisher { $mapItems }

    var region: MKCoordinateRegion = .init()
}

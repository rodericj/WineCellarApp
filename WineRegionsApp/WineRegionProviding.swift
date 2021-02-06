//
//  WineRegionProviding.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 1/10/21.
//

import Foundation
import MapKit
import WineRegionLib
import Combine

enum SelectedRegion {
    case selected(RegionJson)
    case noneSelected
}

protocol WineRegionProviding {
    var currentRegion: CurrentValueSubject<SelectedRegion, Never> { get }
    var wineRegionLib: WineRegion { get }
    var mapItemsPublisher: Published<[MKMapItem]>.Publisher { get }
    var region: MKCoordinateRegion { get set }
}

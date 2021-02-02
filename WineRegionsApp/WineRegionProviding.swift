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
protocol WineRegionProviding {
    var currentRegion: CurrentValueSubject<RegionJson?, Never> { get }
    var wineRegionLib: WineRegion { get }
    var mapItemsPublisher: Published<[MKMapItem]>.Publisher { get }
    var region: MKCoordinateRegion { get set }
}

//
//  WineRegionProviding.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 1/10/21.
//
import Combine
import Foundation
import WineRegionLib
import UIKit

enum SelectedRegion {
    case selected(RegionJson)
    case noneSelected
    
    var title: String? {
        switch self {
        
        case .selected(let region):
            return region.title
        case .noneSelected:
            return nil
        }
    }
}

protocol WineRegionProviding {
    var currentRegion: CurrentValueSubject<SelectedRegion, Never> { get }
    var wineRegionLib: WineRegion { get }
    // TODO put these back in when we want to add items to the map
//    var mapItemsPublisher: Published<[MKMapItem]>.Publisher { get }
//    var region: MKCoordinateRegion { get set }
    var mapZoom: CGFloat { get set }
}

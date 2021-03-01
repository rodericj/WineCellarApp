//
//  WineMapType.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 2/28/21.
//

import Foundation
import MapKit
enum WineMapType: Identifiable {
    var id: String {
        switch self {
        case .MapKit(let type):
            return "MapKit" + String(type.rawValue)
        case .MapBox(let type):
            return "MapBox" + String(type.hashValue)
        }
    }
    
    enum MapBoxType {
        case shadows
        case bigMountains
    }
    
    case MapKit(MKMapType)
    case MapBox(MapBoxType)
    
    var title: String {
        switch self {
        case .MapBox:
            return "Terrain"
        case .MapKit:
            return "Standard"
        }
    }
    var isMapKit: Bool {
        switch self {
        case .MapKit(_):
            return true
        case .MapBox(_):
            return false
        }
    }
    
    var action: (() -> Void) {
        return {
            print(self.title)
        }
    }
}

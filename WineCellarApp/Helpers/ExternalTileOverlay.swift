//
//  OpenStreetMapTileOverlay.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 12/14/20.
//

import Foundation
import MapKit

class ExternalTileOverlay: MKTileOverlay {
    enum Template: String {
        case openstreetMap
        case here
        case here2

        var template: String {
            switch self {
            case .openstreetMap:
                return "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
            case .here:
                return "https://1.aerial.maps.api.here.com/maptile/2.1/maptile/newest/terrain.day/{z}/{x}/{y}/256/png8?app_id=8cHIGJgCmGmlhnDHZNqP&app_code=b_OdG0yyG_MhQAAYBP43wBajIGyT5hw7k8GmpKKar-Y"
            case .here2:
                return "https://1.base.maps.ls.hereapi.com/maptile/2.1/maptile/newest/normal.day.transit/{z}/{x}/{y}/256/png8?app_id=8cHIGJgCmGmlhnDHZNqP&app_code=b_OdG0yyG_MhQAAYBP43wBajIGyT5hw7k8GmpKKar-Y"
            }
        }
    }
    init(source: Template) {
        super.init(urlTemplate: source.template)
        canReplaceMapContent = true
    }
}

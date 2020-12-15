//
//  OpenStreetMapTileOverlay.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 12/14/20.
//

import Foundation
import MapKit

class OpenStreetMapTileOverlay: MKTileOverlay {
    init() {
        super.init(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
        canReplaceMapContent = true
    }
}

//
//  ChateauxSearch.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 1/8/21.
//

import Foundation

class ChateauxSearch: ObservableObject {
    @Published var searchString: String = ""
}

class SubregionCreation: ObservableObject {
    struct NewRegion {
        let title: String
        let parentRegion: UUID
        let geoJsonData: Data
    }
    @Published var newRegion: NewRegion?
}

class RegionFilter: ObservableObject {
    @Published var filterString: String = ""
}

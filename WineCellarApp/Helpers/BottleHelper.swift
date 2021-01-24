//
//  BottleHelper.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 12/4/20.
//

import WineCellar
import WineRegionLib

// For search functionality
extension Bottle {
    func filter(on searchText: String) -> Bool {
        appellation.contains(searchText) ||
            country.contains(searchText) ||
            description.contains(searchText) ||
            designation.contains(searchText) ||
            locale.contains(searchText) ||
//            location.contains(searchText) ||
            masterVarietal.contains(searchText) ||
            String(price).contains(searchText) ||
            producer.contains(searchText) ||
            region.contains(searchText) ||
            sortProducer.contains(searchText) ||
            subRegion.contains(searchText) ||
            title.contains(searchText) ||
            type.rawValue.contains(searchText) ||
            varietal.contains(searchText) ||
            vineyard.contains(searchText) ||
            vintage.contains(searchText)
    }
}

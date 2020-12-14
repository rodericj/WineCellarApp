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

// For marrying our nav information with the bottle object
extension Bottle {

    private func usaRegion() -> AppelationDescribable? {
        switch region {
        case USA.California.title:
            let app =  USA.California.Appelation(rawValue: appellation)
            if app == nil {
                print("No mapping for CA appellation \(appellation)")
            }
            return app
        default:
            return nil
        }
    }

    private func italyRegion() -> AppelationDescribable? {
        switch region {
        case Italy.Tuscany.title:
            return Italy.Tuscany.Appelation(appellation)
        default:
            return nil
        }
    }

    private func frenchRegion() -> AppelationDescribable? {
        switch region {
        case France.Bordeaux.title:
            let bordeaux = France.Bordeaux.Medoc.Appelation(rawValue: appellation)
            print(appellation)
//            assert(bordeaux != nil, "must define \(appellation)")
            return bordeaux
        case France.Burgundy.title:
            let burgundy = France.Burgundy.Appelation(rawValue: appellation)
            print(appellation)
//            assert(burgundy != nil, "must define \(appellation)")
            return burgundy
        default:
            return nil
        }
    }
    var libAppelation: AppelationDescribable? {
        switch country {
        case France.title:
            return frenchRegion()
        case USA.title:
            return usaRegion()
        case Italy.title:
            return italyRegion()
        default:
            return nil
        }
    }
}

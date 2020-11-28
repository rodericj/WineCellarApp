//
//  MapData.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/27/20.
//

import Foundation
import MapKit

struct RegionProperties: Codable {
    let fid: Int
    let id: String
    let men2010: Float
    let pop2010: Float
    let dep: String
    let surf: Float
    let lib: String

    enum CodingKeys: String, CodingKey {
        case fid = "FID"
        case id = "ID"
        case men2010 = "MEN2010"
        case pop2010 = "POP2010"
        case dep = "DEP"
        case surf = "SURF"
        case lib = "LIB"
    }
}

protocol WineRegionDescribable {
    var codes: [String] { get }
}

fileprivate extension Array where Element == String {
    static let rhône: [String] = ["84000", // Avignon
    ]

    static let burgundy: [String] = ["21000", // Dijon
    ]

    static let bordeaux: [String] = ["33123", // Le Verdon-sur-Mer
                                     "33780", // Soulac-sur-Mer
                                     "33590", // Saint-Vivien-de-Medoc
                                     "33340", // Lesparre-Midoc
                                     "33180", // Saint-Est
                                     "33250", // Pauillac
                                     "33390", // Blaye
                                     "33710", // Bourg-sur-Gironde
                                     "33460", // Margaux
                                     "33112", // Saint-Laurent-Modoc
                                     "33710", // Bourg-sur-Gironde
                                     "33480", // Castelnau-de-Madoc
                                     "33290", // Blanquefort
                                     "33160", // Saint-Mudard-en-Jalles
                                     "33700", // M3rignac
                                     "33600", // Pessac
                                     "33520", // Bruges
                                     "33110", // Le Bouscat
                                     "33200", // Bordeaux
                                     "33185", // Le Haillan
                                     "33320", // Eysines
    ]
}

typealias PostalCodes = [String]

public enum WineRegion {
    case france(France)

    public enum France: WineRegionDescribable {
        case bordeaux
        case burgundy
        case rhône
        var codes: [String] {
            switch self {
            case .rhône:
                return .rhône
            case .bordeaux:
                return .bordeaux
            case .burgundy:
                return .burgundy
            }
        }
    }

}


struct MapData {
    func regionPolygons(with describable: WineRegionDescribable) -> [MKPolygon] {
        let jsonDecoder = JSONDecoder()
        return geoJSONFeatures.filter { feature -> Bool in
            do {
                if let data = feature.properties {
                    let props = try jsonDecoder.decode(RegionProperties.self, from: data)
                    return describable.codes.contains(props.id)
                }
            } catch {
                print(error)
            }
            return false
        }.map { feature in
            feature.geometry
                .map { $0 as? MKPolygon  }
                .compactMap { $0 }
        }.reduce([], +)
    }

    private let geoJSONFeatures: [MKGeoJSONFeature] = {
        guard let franceURL = Bundle.main.url(forResource: "codes_postaux_v5", withExtension: "geojson") else {
            fatalError("missing codes_postaux_v5 for the france data")
        }
        let decoder = MKGeoJSONDecoder()
        let jsonDecoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: franceURL)
            let shapes = try decoder.decode(data)
            return shapes
                .map { $0 as? MKGeoJSONFeature }
                .compactMap { $0 }
        } catch {
            print(error)
            return []
        }
    }()
}

//
//  ActionViewController.swift
//  NominatimConsumerActionExtension
//
//  Created by Roderic Campbell on 1/22/21.
//

import UIKit
import MobileCoreServices
import WineRegionLib
import MapKit
class ActionViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] { // TODO get rid of the !
            print(item)
            for provider in item.attachments! { // TODO get rid of the !
                print(provider)
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    weak var weakMapView = self.mapView
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (contentURL, error) in
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        guard let url = contentURL as? URL else {
                            return
                        }
                        do {
                            let data = try Data(contentsOf: url)
                            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                            let data1 =  try JSONSerialization.data(withJSONObject: jsonResponse!["geometry"]!, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
                            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
                            print(convertedString ?? "defaultvalue")
                            
                            let geoJsonDecoder = MKGeoJSONDecoder()
                            let mapObjects = try? geoJsonDecoder.decode(data1)

                            OperationQueue.main.addOperation { 
                                if let strongMapView = weakMapView, let mapObjects = mapObjects {
                                    strongMapView.add(features: mapObjects.compactMap { $0 as? MapKitOverlayable })
                                    
                                    var mapRect: MKMapRect = .null
                                    strongMapView.overlays.forEach { overlay in
                                        mapRect = mapRect.union(overlay.boundingMapRect)
                                    }
                                    
                                    let inset = UIScreen.main.bounds.size.width * 0.05
                                    let padding =  UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
                                    
                                    strongMapView.setVisibleMapRect(mapRect,
                                                              edgePadding: padding,
                                                              animated: true)
                                }
                            }
                            
                        } catch {
                            print(error)
                            return
                        }
                    })
                }
            }

        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}

extension ActionViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // use this tile renderer when the user selects it

        if let overlay = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.2)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 1
            return renderer
        }
        return MKOverlayRenderer()
    }
}

import SwiftUI

class RegionListViewController: UIViewController {
    let dataStore = DataStore()
    @IBSegueAction func test(_ coder: NSCoder) -> UIViewController? {
        dataStore.wineRegionLib.getRegionTree()
        return UIHostingController(coder: coder,
                                   rootView: ExtensionRegionList(dataStore: dataStore))
    }
    
}

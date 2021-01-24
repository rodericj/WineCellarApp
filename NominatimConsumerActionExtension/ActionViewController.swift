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

enum ActionError: Error {
    case invalidDataFormat
    case missingTitle
    case invalidGeoJson
}

class ActionViewController: UIViewController {

    var newRegionData: NewRegionData? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let regionList = segue.destination as? RegionListViewController
        regionList?.newRegion = newRegionData
    }
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
                
        extensionContext?.inputItems
            .compactMap { $0 as? NSExtensionItem }
            .map { $0.attachments }
            .compactMap { $0 }
            .forEach{ providerArray in
                providerArray
                    .filter { $0.hasItemConformingToTypeIdentifier(kUTTypeURL as String) }
                    .forEach { provider in
                        provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { [weak self] (contentURL, error) in
                            weak var weakMapView = self?.mapView
                            
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            guard let url = contentURL as? URL else {
                                return
                            }
                            
                            do {
                                let data = try Data(contentsOf: url)
                                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                                guard let jsonResponse =  jsonObject as? [String: AnyObject] else {
                                    throw ActionError.invalidDataFormat
                                }
                                guard let name = jsonResponse["localname"] as? String else {
                                    throw ActionError.missingTitle
                                }
                                guard let geometry = jsonResponse["geometry"] else {
                                    throw ActionError.invalidGeoJson
                                }
                                
                                // first of all convert json to the data
                                let geoJson =  try JSONSerialization.data(withJSONObject: geometry,
                                                                          options: JSONSerialization.WritingOptions.prettyPrinted)
                                self?.newRegionData = NewRegionData(title: name, geoJson: geoJson)
                                
                                let geoJsonDecoder = MKGeoJSONDecoder()
                                let mapObjects = try? geoJsonDecoder.decode(geoJson)
                                
                                OperationQueue.main.addOperation {
                                    if let strongMapView = weakMapView, let mapObjects = mapObjects {
                                        strongMapView.add(features: mapObjects.compactMap { $0 as? MapKitOverlayable })
                                        strongMapView.zoomToOverlays()
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

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}

extension MKMapView {
    func zoomToOverlays() {
        var mapRect: MKMapRect = .null
        overlays.forEach { overlay in
            mapRect = mapRect.union(overlay.boundingMapRect)
        }
        
        let inset = UIScreen.main.bounds.size.width * 0.05
        let padding =  UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        setVisibleMapRect(mapRect,
                          edgePadding: padding,
                          animated: true)
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
    
    var newRegion: NewRegionData? = nil
    
    @IBSegueAction func embedRegionList(_ coder: NSCoder) -> UIViewController? {
        guard let newRegion = newRegion else { return nil }
        dataStore.wineRegionLib.getRegionTree()
        let regionList = ExtensionRegionList(dataStore: dataStore, newRegion: newRegion)
        return UIHostingController(coder: coder,  rootView: regionList)
    }
    
}

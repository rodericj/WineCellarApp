//
//  SceneDelegate.swift
//  WineRegionsApp
//
//  Created by Roderic Campbell on 12/7/20.
//

import UIKit
import SwiftUI
import Combine
import WineRegionLib
import MapboxMaps
import CoreSpotlight

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let dataStore = DataStore()
    var mapboxMapView: MapboxMapView?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        mapboxMapView = MapboxMapView(dataStore: dataStore)
        
        guard let mapboxMapView = mapboxMapView else {
            print("the mapbox map view was not created.")
            return
        }

        // Create the SwiftUI view that provides the window contents.
        let contentView = RegionNavigation()
            .environmentObject(dataStore.wineRegionLib)
            .environmentObject(mapboxMapView)
            .environmentObject(dataStore)

        dataStore.wineRegionLib.getRegionTree()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == CSSearchableItemActionType,
           let userInfo = userActivity.userInfo,
           let itemIdentifier = userInfo[CSSearchableItemActivityIdentifier] as? String,
           let regionUUID = UUID(uuidString: itemIdentifier) {
            // Assuming we have loaded the region tree, we should be able to update the dataStore
            // TODO it is possible that we do not actually have the data loaded as this is all stored in memory.
            // In this case we would need to have some kind of "on deck" region json which would be picked up by the datastore
            let regionsWithThisUUID = dataStore.regionTree.compactMap { regionJson in
                regionJson.findRegion(with: regionUUID)
            }
            if let matchingRegion = regionsWithThisUUID.first {
                dataStore.currentRegion.send(.selected(matchingRegion))
            }
        }
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


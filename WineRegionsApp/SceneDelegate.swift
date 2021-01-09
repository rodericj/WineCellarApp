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

class DataStore: ObservableObject {
    var searchCancellable: AnyCancellable? = nil
    var chateauxSearch = ChateauxSearch()

    @Published var regionTree: [RegionJson] = []
    @Published var regionTreeLoadingProgress: Float = 0
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let wineRegionLib = WineRegion()
    var treeCancellable: AnyCancellable? = nil
    var mapsCancellable: AnyCancellable? = nil
    let dataStore = DataStore()

    lazy var wineMapView = WineMapView(wineRegionLib: wineRegionLib)


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        wineMapView = WineMapView(wineRegionLib: wineRegionLib)
        wineMapView.translatesAutoresizingMaskIntoConstraints = false
        // Create the SwiftUI view that provides the window contents.
        let contentView = RegionNavigation(wineMapView: wineMapView)
            .environmentObject(wineRegionLib)
            .environmentObject(wineMapView)
            .environmentObject(dataStore)

        wineRegionLib.getRegionTree()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }

        dataStore.searchCancellable = dataStore.chateauxSearch.$searchString
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink { string in
            print("new search string \(string)")
                self.wineMapView.performLocalSearch(query: string)
        }

        mapsCancellable = wineRegionLib.$regionMaps
            .receive(on: DispatchQueue.main)
            .sink { result in
            switch result {
            case .regions:
                self.dataStore.regionTreeLoadingProgress = 0
            case .loading(let progress):
                self.dataStore.regionTreeLoadingProgress = progress
                print("loading from scene delegate \(progress)")
            case .none:
                self.dataStore.regionTreeLoadingProgress = 0
                print("no state for the tree")
            case let .error(error, string):
                self.dataStore.regionTreeLoadingProgress = 0
                print("Error fetching regions tree, probably need to bubble this up \(error): \(string ?? "No error")")
            }
        }

        treeCancellable = wineRegionLib.$regionsTree
            .receive(on: DispatchQueue.main)
            .sink { result in
            switch result {
            case .regions(let tree):
                self.dataStore.regionTree = tree.sorted { $0.title < $1.title }
                self.dataStore.regionTreeLoadingProgress = 0
            case .loading(let progress):
                self.dataStore.regionTreeLoadingProgress = progress
                print("loading from scene delegate \(progress)")
            case .none:
                self.dataStore.regionTreeLoadingProgress = 0
                print("no state for the tree")
            case .error(let error, let string):
                self.dataStore.regionTreeLoadingProgress = 0
                print("Error fetching regions tree, probably need to bubble this up \(error): \(string ?? "No Error")")
            }
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

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


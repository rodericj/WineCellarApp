import Combine
import CoreSpotlight
import MapboxMaps
import OSLog
import SwiftUI
import UIKit
import WineRegionLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let dataStore = DataStore()
    var mapboxMapView: MapboxMapView?
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "RegionSceneDelegate")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        logger.debug(#function)
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        connectionOptions
            .userActivities
            .filter { $0.activityType == CSSearchableItemActionType }
            .compactMap { activity in
                activity.userInfo?[CSSearchableItemActivityIdentifier] as? String
            }.compactMap { itemIdentifier in
                UUID(uuidString: itemIdentifier)
            }.forEach {
                logger.debug("CSSearch for \($0.uuidString)")
                dataStore.queuedRegionUUID.send($0)
            }
        
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
        logger.debug(#function)
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        logger.debug(#function)

    }
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        logger.debug(#function)

    }
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        logger.debug(#function)
        logger.debug("user activity continue")
        if userActivity.activityType == CSSearchableItemActionType,
           let userInfo = userActivity.userInfo,
           let itemIdentifier = userInfo[CSSearchableItemActivityIdentifier] as? String,
           let regionUUID = UUID(uuidString: itemIdentifier) {
            logger.debug("this is the UIUD \(regionUUID)")
            dataStore.queuedRegionUUID.send(regionUUID)
        }
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        logger.debug(#function)
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


//
//  WineRegionEditorApp.swift
//  WineRegionEditor
//
//  Created by Roderic Campbell on 2/11/21.
//

import Combine
import SwiftUI

@main
struct WineRegionEditorApp: App {
    let dataStore = DataStore()
    var cancellables: [AnyCancellable] = []

    init() {
        dataStore.getRegionTree()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(dataStore)
        }
    }
}

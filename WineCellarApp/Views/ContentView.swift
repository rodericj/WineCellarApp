//
//  ContentView.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar

class UserAuth: ObservableObject {
    @Published var isLoggedin: Bool = false

    func login() {
        self.isLoggedin = true
    }
}


struct ContentView: View {
    @EnvironmentObject var userAuth: UserAuth
    var body: some View {
        if !userAuth.isLoggedin {
            return AnyView(LoginView())
        } else {
            return AnyView(WineBottleNav())
        }

    }
}

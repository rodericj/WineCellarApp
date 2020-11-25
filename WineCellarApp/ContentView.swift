//
//  ContentView.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar

class UserAuth: ObservableObject {
    @Published var isLoggedin:Bool = false

    func login() {
        self.isLoggedin = true
    }
}


struct ContentView: View {

    @EnvironmentObject var userAuth: UserAuth
    let cellar: WineCellar // TODO maybe this is an environment

    var body: some View {
        if !userAuth.isLoggedin {
            return AnyView(LoginView(cellar: cellar))
        } else {
            return AnyView(WineBottleList(cellar: cellar))
        }

    }
}

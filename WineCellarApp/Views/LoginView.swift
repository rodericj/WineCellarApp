//
//  ContentView.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/24/20.
//

import SwiftUI
import WineCellar

struct LoginView: View {
    @State var uname: String = ""
    @State var password: String = ""
    @EnvironmentObject var userAuth: UserAuth
    @EnvironmentObject var cellar: WineCellar

    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

    var body: some View {

        VStack {
            Spacer()
        VStack {
            Text("Login with CellarTracker.com credentials")
            TextField("User name", text: $uname)
                .padding()
                .background(Color.secondary)
                .foregroundColor(Color.primary)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            SecureField("Password", text: $password)
                .padding()
                .background(Color.secondary)
                .foregroundColor(Color.primary)
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Button("Login") {
                cellar.refreshCellar(uname: uname,
                                     password: password)
            }
            .padding()
            .background(Color.secondary)
            .foregroundColor(Color.primary)
            .cornerRadius(5)
        }.padding()

        .frame(maxWidth: 320)
        .border(Color.secondary, width: 1)
            Spacer()
            Text("Test user: roddyj\nPassword: carcarcar")
                .foregroundColor(.gray).italic()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(WineCellar())
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhoen SE")

        LoginView().environmentObject(WineCellar())
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (2nd generation)"))
            .previewDisplayName("iPad")
    }
}

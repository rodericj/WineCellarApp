//
//  SearchBar.swift
//  WineCellarApp
//
//  Created by Roderic Campbell on 11/26/20.
//

import SwiftUI

struct SearchBar: View {
    var placeholder: String

    @Binding var text: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(.all, 15)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 5)
                )

            if text != "" {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(Color(.systemGray3))
                    .padding(3)
                    .onTapGesture {
                        withAnimation {
                            self.text = ""
                        }
                    }
            }

        }
    }
}

struct SearchBar_Previews: PreviewProvider {

    static var previews: some View {
        SearchBar(placeholder: "Search", text: .constant("hi"))
    }
}

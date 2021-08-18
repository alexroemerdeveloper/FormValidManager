//
//  ContentView.swift
//  FormValidManager
//
//  Created by Alexander Römer on 11.07.21.
//
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var formViewModel = FormViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("USERNAME")) {
                        TextField("Username", text: $formViewModel.username)
                            .autocapitalization(.none)
                    }
                    
                    Section(header: Text("PASSWORD"), footer: Text(formViewModel.inlineErrorForPassword).foregroundColor(.red)) {
                        TextField("Password", text: $formViewModel.password)
                            .autocapitalization(.none)
                        TextField("Password again", text: $formViewModel.passwordAgain)
                            .autocapitalization(.none)
                    }
                }
                
                Button(action: { } ) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 60)
                        .overlay(Text("Continue"))
                }
                .padding()
                .disabled(!formViewModel.isValid)
               
            }
            .navigationTitle("Sign up")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

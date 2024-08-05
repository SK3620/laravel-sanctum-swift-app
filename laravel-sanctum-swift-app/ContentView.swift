//
//  ContentView.swift
//  laravel-sanctum-swift-app
//
//  Created by 鈴木 健太 on 2024/08/05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $isLoginMode, label: Text("Picker here")) {
                    Text("Login").tag(true)
                    Text("Register").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if !isLoginMode {
                    TextField("Name", text: $authViewModel.name)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                }
                
                TextField("Email", text: $authViewModel.email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                SecureField("Password", text: $authViewModel.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: {
                    if isLoginMode {
                        authViewModel.login()
                    } else {
                        authViewModel.register()
                    }
                }) {
                    Text(isLoginMode ? "Login" : "Register")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(5.0)
                }
                .padding()
                
                Spacer()
                
                NavigationLink {
                    TodoListView(token: authViewModel.token ?? "なし")
                } label: {
                    Text(authViewModel.isAuthenticated ? "ToDoList画面" : "not authenticated")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(5.0)
                }
            }
            .padding()
            .navigationTitle(isLoginMode ? "Login" : "Register")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  AuthViewModel.swift
//  laravel-sanctum-swift-app
//
//  Created by 鈴木 健太 on 2024/08/05.
//

import Foundation
import SwiftUI
import Combine

struct User: Codable {
    var name: String?
    var email: String
    var password: String
}

struct TokenResponse: Codable {
    var token: String
}

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var token: String?

    private var cancellables = Set<AnyCancellable>()

    func register() {
        guard let url = URL(string: "http://localhost:8000/api/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let user = User(name: name, email: email, password: password)
        guard let encoded = try? JSONEncoder().encode(user) else {
            print("Failed to encode user")
            return
        }

        request.httpBody = encoded

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: User.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Registration failed: \(error.localizedDescription)"
                case .finished:
                    self.errorMessage = nil
                }
            }, receiveValue: { user in
                self.isAuthenticated = true
            })
            .store(in: &cancellables)
    }

    func login() {
        guard let url = URL(string: "") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let user = User(name: nil, email: email, password: password)
        guard let encoded = try? JSONEncoder().encode(user) else {
            print("Failed to encode user")
            return
        }

        request.httpBody = encoded

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                case .finished:
                    self.errorMessage = nil
                }
            }, receiveValue: { tokenResponse in
                self.token = tokenResponse.token
                self.isAuthenticated = true
            })
            .store(in: &cancellables)
    }
}

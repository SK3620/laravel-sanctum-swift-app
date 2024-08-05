//
//  ToDoViewModel.swift
//  laravel-sanctum-swift-app
//
//  Created by 鈴木 健太 on 2024/08/05.
//

import SwiftUI
import Combine

struct Todo: Identifiable, Codable {
    var id: Int
    var title: String
}

class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var newTodoTitle: String = ""
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let baseUrl = "http://localhost:8000/api"
    private let token: String

    init(token: String) {
        self.token = token
        fetchTodos()
    }

    func fetchTodos() {
        guard let url = URL(string: "\(baseUrl)/todos") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Todo].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Failed to fetch todos: \(error.localizedDescription)"
                case .finished:
                    self.errorMessage = nil
                }
            }, receiveValue: { todos in
                self.todos = todos
            })
            .store(in: &cancellables)
    }

    func addTodo() {
        guard let url = URL(string: "http://localhost:8000/api/todos") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let newTodo = ["title": newTodoTitle]
        guard let encoded = try? JSONEncoder().encode(newTodo) else {
            print("Failed to encode new todo")
            return
        }

        request.httpBody = encoded

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: Todo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Failed to add todo: \(error.localizedDescription)"
                case .finished:
                    self.errorMessage = nil
                }
            }, receiveValue: { todo in
                self.todos.append(todo)
                self.newTodoTitle = ""
            })
            .store(in: &cancellables)
    }

    func deleteTodo(_ todo: Todo) {
        guard let url = URL(string: "\(baseUrl)/todos/\(todo.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Failed to delete todo: \(error.localizedDescription)"
                case .finished:
                    self.errorMessage = nil
                }
            }, receiveValue: { _ in
                self.todos.removeAll { $0.id == todo.id }
            })
            .store(in: &cancellables)
    }
}

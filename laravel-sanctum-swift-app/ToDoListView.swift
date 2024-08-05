//
//  ToDoListView.swift
//  laravel-sanctum-swift-app
//
//  Created by 鈴木 健太 on 2024/08/05.
//

import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel: TodoViewModel
    @State private var showAlert: Bool = false

    init(token: String) {
        _viewModel = StateObject(wrappedValue: TodoViewModel(token: token))
    }

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.todos) { todo in
                    HStack {
                        Text(todo.title)
                        Spacer()
                        Button(action: {
                            viewModel.deleteTodo(todo)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchTodos()
            }

            HStack {
                TextField("New Todo", text: $viewModel.newTodoTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    viewModel.addTodo()
                }) {
                    Text("Add")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            .padding()

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Todo List")
    }
}

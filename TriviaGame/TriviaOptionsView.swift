//
//  ContentView.swift
//  TriviaGame
//
//  Created by Daniela Garcia on 3/12/25.
//

import SwiftUI

struct TriviaOptionsView: View {
    @StateObject private var viewModel = TriviaViewModel()
    
    @State private var numberOfQuestions: String = "10" // Default value
    @State private var selectedTimer: Int?
    @State private var startGame = false
    
    let timerOptions = [30, 60, 120, 300, 600] // 30s, 1min, 2min, 5min, 10min
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Trivia Game")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Form {
                    // Number of Questions
                    Section(header: Text("Number of Questions")) {
                        TextField("Enter a number", text: $numberOfQuestions)
                            .keyboardType(.numberPad)
                            .onChange(of: numberOfQuestions) { newValue in
                                if let amount = Int(newValue), amount > 0 {
                                    viewModel.fetchDifficultiesAndTypes(for: amount)
                                }
                            }
                    }
                    
                    // Category Picker
                    Section(header: Text("Select Category")) {
                        if viewModel.categories.isEmpty {
                            ProgressView("Loading categories...")
                        } else {
                            Picker("Category", selection: $viewModel.selectedCategory) {
                                ForEach(viewModel.categories) { category in
                                    Text(category.name).tag(category.id)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    
                    // Difficulty Picker (Now dynamic)
                    Section(header: Text("Difficulty")) {
                        if viewModel.difficulties.isEmpty {
                            ProgressView("Loading difficulties...")
                        } else {
                            Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                                ForEach(Array(viewModel.difficulties), id: \.self) { difficulty in
                                    Text(difficulty.capitalized).tag(difficulty)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    
                    // Type Picker (Now dynamic)
                    Section(header: Text("Select Type")) {
                        if viewModel.types.isEmpty {
                            ProgressView("Loading question types...")
                        } else {
                            Picker("Type", selection: $viewModel.selectedType) {
                                ForEach(Array(viewModel.types), id: \.self) { type in
                                    Text(type.capitalized).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    
                    // Timer Picker
                    Section(header: Text("Timer Duration")) {
                        Picker("Time", selection: $selectedTimer) {
                            ForEach(timerOptions, id: \.self) { time in
                                Text("\(time) seconds").tag(time)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // Start Trivia Button
                Button(action: {
                    if let amount = Int(numberOfQuestions), amount > 0 {
                        viewModel.fetchTriviaQuestions(
                            amount: amount,
                            category: viewModel.selectedCategory,
                            difficulty: viewModel.selectedDifficulty,
                            type: viewModel.selectedType
                        )
                        startGame = true // Navigate to game screen
                    }
                }) {
                    Text("Start Trivia")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled( viewModel.selectedCategory == nil ||
                           viewModel.selectedDifficulty == nil ||
                           viewModel.selectedType == nil ||
                           selectedTimer == nil)
                
                // Navigation to Trivia Game Screen
                NavigationLink(
                    destination: TriviaGameView(questions: viewModel.questions, timerDuration: selectedTimer ?? 30), // ❌ No hardcoded 30
                    isActive: $startGame
                ) {
                    EmptyView()
                }
            }
                
                .navigationBarHidden(true)
        }
    }
}

#Preview {
    TriviaOptionsView()
}

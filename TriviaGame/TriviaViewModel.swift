//
//  TriviaViewModel.swift
//  TriviaGame
//
//  Created by Daniela Garcia on 3/12/25.
//

import Foundation
import SwiftUI

class TriviaViewModel: ObservableObject {
    @Published var categories: [TriviaCategory] = []
    @Published var difficulties: Set<String> = []
    @Published var types: Set<String> = []
    @Published var selectedCategory: Int?
    @Published var selectedDifficulty: String?
    @Published var selectedType: String?
    @Published var questions: [TriviaQuestion] = [] // Stores fetched trivia questions
    
    init() {
        fetchCategories()
    }
    
    func fetchCategories() {
        guard let url = URL(string: "https://opentdb.com/api_category.php") else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.categories = decodedResponse.trivia_categories
                    self.selectedCategory = self.categories.first?.id
                }
            } catch {
                print("Error fetching categories: \(error)")
            }
        }
    }

    func fetchDifficultiesAndTypes(for amount: Int) {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=\(amount)") else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                
                DispatchQueue.main.async {
                    let fetchedDifficulties = Set(decodedResponse.results.map { $0.difficulty })
                    let fetchedTypes = Set(decodedResponse.results.map { $0.type })

                    self.difficulties = fetchedDifficulties
                    self.selectedDifficulty = self.difficulties.first

                    self.types = fetchedTypes
                    self.selectedType = self.types.first
                }
            } catch {
                print("Error fetching difficulties and types: \(error)")
            }
        }
    }

    func fetchTriviaQuestions(amount: Int, category: Int?, difficulty: String?, type: String?) {
        var urlString = "https://opentdb.com/api.php?amount=\(amount)"
        
        if let category = category {
            urlString += "&category=\(category)"
        }
        if let difficulty = difficulty {
            urlString += "&difficulty=\(difficulty)"
        }
        if let type = type {
            urlString += "&type=\(type)"
        }

        guard let url = URL(string: urlString) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.questions = decodedResponse.results
                    print("Fetched \(self.questions.count) questions")
                }
            } catch {
                print("Error fetching trivia questions: \(error)")
            }
        }
    }
}

// Model for Trivia API response
struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Identifiable {
    let id = UUID() // Unique identifier for SwiftUI lists
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    let type: String
    let difficulty: String
    
    var allAnswers: [String] {
            ([correct_answer] + incorrect_answers) // ✅ Mix answers randomly
        }
}

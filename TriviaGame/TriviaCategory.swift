//
//  TriviaCategory.swift
//  TriviaGame
//
//  Created by Daniela Garcia on 3/12/25.
//

import Foundation

struct TriviaCategory: Codable, Identifiable {
    let id: Int
    let name: String
}

struct CategoryResponse: Codable {
    let trivia_categories: [TriviaCategory]
}

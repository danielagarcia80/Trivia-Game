//
//  TriviaGameView.swift
//  TriviaGame
//
//  Created by Daniela Garcia on 3/13/25.
//

import SwiftUI

struct TriviaGameView: View {
    let questions: [TriviaQuestion]
    let timerDuration: Int
    
    @State private var selectedAnswers: [UUID: String] = [:]
    @State private var score: Int?
    @State private var showScoreAlert = false
    @State private var timeRemaining: Int
    @State private var timerRunning = true
    @State private var timer: Timer?
    @State private var submitted = false // ✅ Tracks if answers were submitted

    init(questions: [TriviaQuestion], timerDuration: Int) {
        self.questions = questions
        self.timerDuration = timerDuration
        _timeRemaining = State(initialValue: timerDuration)
    }

    var body: some View {
        VStack {
            // ✅ Countdown Timer
            Text("Time remaining: \(timeRemaining)s")
                .font(.title2)
                .bold()
                .padding()
                .onAppear {
                    startTimer()
                }

            List(questions) { question in
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.question)
                        .font(.headline)
                    
                    ForEach(question.allAnswers, id: \.self) { answer in
                        Button(action: {
                            if !submitted { // ✅ Allow selection before submission
                                selectedAnswers[question.id] = answer
                            }
                        }) {
                            HStack {
                                Text(answer)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(getAnswerColor(question: question, answer: answer)) // ✅ Show selection color
                                    .cornerRadius(10)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }

            Button("Submit Answers") {
                submitAnswers()
            }
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .disabled(submitted) // ✅ Disable button after submission
        }
        .navigationTitle("Trivia Game")
        .alert(isPresented: $showScoreAlert) {
            Alert(
                title: Text("Game Over"),
                message: Text("You scored \(score ?? 0) out of \(questions.count)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // ✅ Only highlight selected answer (Green = Correct, Red = Incorrect)
    func getAnswerColor(question: TriviaQuestion, answer: String) -> Color {
        guard submitted else {
            return selectedAnswers[question.id] == answer ? Color.blue.opacity(0.5) : Color.clear
        }
        
        if selectedAnswers[question.id] == answer {
            return answer == question.correct_answer ? Color.green.opacity(0.5) : Color.red.opacity(0.5)
        }

        return Color.clear // ✅ Unselected answers stay the same
    }

    // ✅ Start the Countdown Timer
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                if timeRemaining > 0 && timerRunning {
                    timeRemaining -= 1
                } else {
                    timer.invalidate()
                    submitAnswers()
                }
            }
        }
    }

    // ✅ Stop Timer and Calculate Score
    func submitAnswers() {
        DispatchQueue.main.async {
            timer?.invalidate()
            timer = nil
            timerRunning = false
        }

        var correctCount = 0
        
        for question in questions {
            if let userAnswer = selectedAnswers[question.id], userAnswer == question.correct_answer {
                correctCount += 1
            }
        }
        
        score = correctCount
        submitted = true // ✅ Mark answers as submitted
        showScoreAlert = true // ✅ Show the score alert
    }
}


#Preview {
    TriviaGameView(questions: [], timerDuration: 60)
}

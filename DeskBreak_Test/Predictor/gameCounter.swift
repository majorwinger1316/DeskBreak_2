//
//  gameCounter.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 13/11/24.
//

import Foundation
import SwiftUI

struct Exercise: Identifiable {
    var id = UUID()
    var name: String
    var points: Int
    var minutes: Int
    var posture: Posture
}

enum Posture: String {
    case correct
    case incorrect
}

class ExerciseDataModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var totalPoints: Int = 0

    func updatePoints(for exercise: Exercise) {
        if exercise.posture == .correct {
            totalPoints += exercise.points
        } else {
            totalPoints += max(0, exercise.points / 2)
        }
        exercises.append(exercise)
    }
}

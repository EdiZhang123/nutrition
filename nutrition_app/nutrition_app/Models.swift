// Models.swift
// nutrition_app

import Foundation

struct UserProfile: Codable {
    var ageRange: String
    var height: String
    var weight: String
    var lifestyle: String
    var healthGoal: String
}

enum HealthGoal: String, CaseIterable, Identifiable {
    case fatLoss = "Fat Loss"
    case muscleGain = "Muscle Gain"
    case wholeFoods = "Whole Foods"
    case athleticPerformance = "Athletic Performance"
    case budget = "Budget"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fatLoss: return "flame.fill"
        case .muscleGain: return "dumbbell.fill"
        case .wholeFoods: return "leaf.fill"
        case .athleticPerformance: return "bolt.fill"
        case .budget: return "dollarsign.circle.fill"
        }
    }
}

struct NutritionResponse: Identifiable {
    var id = UUID()
    var food: String
    var lenses: [LensResult]
    var alternatives: [String]
}

struct LensResult: Identifiable {
    var id = UUID()
    var name: String
    var verdict: String
    var reason: String
}

// NutritionService.swift
// nutrition_app

import Foundation

class NutritionService {
    static let shared = NutritionService()

    private let backendURL = "http://localhost:3000/analyze"

    // MARK: - Public API

    func analyze(food: String, goal: String, profile: UserProfile?) async -> NutritionResponse {
        if let response = await callBackend(food: food, goal: goal, profile: profile) {
            return response
        }
        // Fallback to mock data when backend is unreachable (offline dev, no key yet)
        print("[NutritionService] Backend unavailable — using mock data")
        return mockResponse(for: food)
    }

    // MARK: - Network

    private func callBackend(food: String, goal: String, profile: UserProfile?) async -> NutritionResponse? {
        guard let url = URL(string: backendURL) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20

        let body = AnalyzeRequestBody(
            food: food,
            goal: goal,
            profile: profile ?? UserProfile(ageRange: "", height: "", weight: "", lifestyle: "", healthGoal: "")
        )

        guard let encoded = try? JSONEncoder().encode(body) else { return nil }
        request.httpBody = encoded

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            let dto = try JSONDecoder().decode(NutritionResponseDTO.self, from: data)
            return dto.toModel()
        } catch {
            print("[NutritionService] Error: \(error)")
            return nil
        }
    }

    // MARK: - Codable DTOs (network layer only)

    private struct AnalyzeRequestBody: Encodable {
        let food: String
        let goal: String
        let profile: UserProfile
    }

    private struct NutritionResponseDTO: Decodable {
        let food: String
        let lenses: [LensDTO]
        let alternatives: [String]

        struct LensDTO: Decodable {
            let name: String
            let verdict: String
            let reason: String
        }

        func toModel() -> NutritionResponse {
            NutritionResponse(
                food: food,
                lenses: lenses.map { LensResult(name: $0.name, verdict: $0.verdict, reason: $0.reason) },
                alternatives: alternatives
            )
        }
    }

    // MARK: - Mock fallback

    private func mockResponse(for food: String) -> NutritionResponse {
        let mockData: [String: NutritionResponse] = [
            "eggs": NutritionResponse(
                food: "Eggs",
                lenses: [
                    LensResult(name: "Fat Loss", verdict: "✅", reason: "High protein, moderate calories — keeps you full and supports fat burning."),
                    LensResult(name: "Muscle Gain", verdict: "✅", reason: "Complete protein with all essential amino acids, ideal for muscle synthesis."),
                    LensResult(name: "Whole Foods", verdict: "✅", reason: "Minimally processed whole food packed with vitamins and healthy fats."),
                    LensResult(name: "Athletic Performance", verdict: "✅", reason: "Rich in choline and B vitamins that support energy metabolism and recovery."),
                    LensResult(name: "Budget", verdict: "✅", reason: "One of the cheapest high-quality protein sources at roughly $0.20 per egg.")
                ],
                alternatives: ["Greek yogurt", "Cottage cheese", "Tuna"]
            ),
            "protein bar": NutritionResponse(
                food: "Protein Bar",
                lenses: [
                    LensResult(name: "Fat Loss", verdict: "⚠️", reason: "Convenient but often high in sugar — check labels and limit to one per day."),
                    LensResult(name: "Muscle Gain", verdict: "✅", reason: "Quick protein fix post-workout, though whole food sources are superior."),
                    LensResult(name: "Whole Foods", verdict: "❌", reason: "Heavily processed with artificial ingredients, sugar alcohols, and additives."),
                    LensResult(name: "Athletic Performance", verdict: "⚠️", reason: "Useful for on-the-go fueling but real food performs better around training."),
                    LensResult(name: "Budget", verdict: "❌", reason: "Expensive per gram of protein compared to eggs, chicken, or Greek yogurt.")
                ],
                alternatives: ["Hard-boiled eggs", "Greek yogurt", "Handful of almonds"]
            ),
            "white rice": NutritionResponse(
                food: "White Rice",
                lenses: [
                    LensResult(name: "Fat Loss", verdict: "⚠️", reason: "High glycemic index spikes blood sugar — pair with protein and vegetables."),
                    LensResult(name: "Muscle Gain", verdict: "✅", reason: "Fast-digesting carbs replenish glycogen quickly after intense training."),
                    LensResult(name: "Whole Foods", verdict: "⚠️", reason: "Refined grain with fiber and nutrients removed compared to brown rice."),
                    LensResult(name: "Athletic Performance", verdict: "✅", reason: "Classic performance fuel — easy to digest before and after workouts."),
                    LensResult(name: "Budget", verdict: "✅", reason: "Extremely cost-effective staple carbohydrate at cents per serving.")
                ],
                alternatives: ["Brown rice", "Quinoa", "Sweet potato"]
            )
        ]

        let key = food.lowercased().trimmingCharacters(in: .whitespaces)
        return mockData[key] ?? NutritionResponse(
            food: food.capitalized,
            lenses: [
                LensResult(name: "Fat Loss", verdict: "⚠️", reason: "Evaluate portion size and macros before including in a fat loss diet."),
                LensResult(name: "Muscle Gain", verdict: "⚠️", reason: "Assess protein content relative to overall caloric intake for muscle goals."),
                LensResult(name: "Whole Foods", verdict: "⚠️", reason: "Check the ingredient list — choose the least processed version available."),
                LensResult(name: "Athletic Performance", verdict: "⚠️", reason: "Consider timing and digestibility relative to your training schedule."),
                LensResult(name: "Budget", verdict: "⚠️", reason: "Compare cost per gram of protein or calorie against whole food alternatives.")
            ],
            alternatives: ["Chicken breast", "Brown rice", "Broccoli"]
        )
    }
}

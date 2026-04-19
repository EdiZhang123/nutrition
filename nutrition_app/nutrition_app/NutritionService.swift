// NutritionService.swift
// nutrition_app

import Foundation

class NutritionService {
    static let shared = NutritionService()

    private let mockData: [String: NutritionResponse] = [
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
        ),
        "avocado": NutritionResponse(
            food: "Avocado",
            lenses: [
                LensResult(name: "Fat Loss", verdict: "⚠️", reason: "Healthy fats but calorie-dense — stick to half an avocado per serving."),
                LensResult(name: "Muscle Gain", verdict: "✅", reason: "Provides healthy fats and potassium that support muscle recovery."),
                LensResult(name: "Whole Foods", verdict: "✅", reason: "Nutrient-dense whole food packed with fiber, vitamins, and healthy fats."),
                LensResult(name: "Athletic Performance", verdict: "✅", reason: "Potassium and B vitamins support endurance and reduce muscle cramps."),
                LensResult(name: "Budget", verdict: "❌", reason: "Premium price point at $1–2 each, and availability fluctuates seasonally.")
            ],
            alternatives: ["Olive oil", "Nuts", "Flaxseeds"]
        ),
        "chicken breast": NutritionResponse(
            food: "Chicken Breast",
            lenses: [
                LensResult(name: "Fat Loss", verdict: "✅", reason: "Lean protein with very low fat — a cornerstone of fat loss diets."),
                LensResult(name: "Muscle Gain", verdict: "✅", reason: "High-quality complete protein with excellent amino acid profile for growth."),
                LensResult(name: "Whole Foods", verdict: "✅", reason: "Minimally processed whole food with no additives when bought fresh."),
                LensResult(name: "Athletic Performance", verdict: "✅", reason: "Versatile lean protein that supports recovery without excess calories."),
                LensResult(name: "Budget", verdict: "✅", reason: "One of the most cost-effective lean proteins, especially bought in bulk.")
            ],
            alternatives: ["Turkey breast", "Canned tuna", "Tofu"]
        ),
        "soda": NutritionResponse(
            food: "Soda",
            lenses: [
                LensResult(name: "Fat Loss", verdict: "❌", reason: "Pure liquid sugar with zero nutrients — directly sabotages fat loss efforts."),
                LensResult(name: "Muscle Gain", verdict: "❌", reason: "Empty calories with no protein or nutrients to support muscle growth."),
                LensResult(name: "Whole Foods", verdict: "❌", reason: "Highly processed with artificial flavors, colors, and excessive added sugar."),
                LensResult(name: "Athletic Performance", verdict: "❌", reason: "Sugar crash and acidity impair performance and slow recovery."),
                LensResult(name: "Budget", verdict: "⚠️", reason: "Cheap upfront but poor value — zero nutritional return on spend.")
            ],
            alternatives: ["Sparkling water", "Coconut water", "Herbal tea"]
        )
    ]

    func analyze(food: String, goal: String) async -> NutritionResponse {
        // Simulate a network round-trip
        try? await Task.sleep(nanoseconds: 1_200_000_000)

        let key = food.lowercased().trimmingCharacters(in: .whitespaces)
        if let result = mockData[key] {
            return result
        }

        // Generic fallback for unrecognized foods
        return NutritionResponse(
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

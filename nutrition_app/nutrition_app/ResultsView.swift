// ResultsView.swift
// nutrition_app

import SwiftUI

struct ResultsView: View {
    let response: NutritionResponse
    let primaryGoal: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text("Results for")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(response.food)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Divider()

            // Lens cards
            VStack(spacing: 10) {
                ForEach(response.lenses) { lens in
                    LensCard(lens: lens, isPrimary: lens.name == primaryGoal)
                }
            }

            // Alternatives
            if !response.alternatives.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Better alternatives for your goal", systemImage: "arrow.up.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    VStack(spacing: 8) {
                        ForEach(response.alternatives, id: \.self) { alt in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                                Text(alt)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(16)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
}

// MARK: - LensCard

struct LensCard: View {
    let lens: LensResult
    let isPrimary: Bool

    private var verdictColor: Color {
        switch lens.verdict {
        case "✅": return .green
        case "⚠️": return .orange
        case "❌": return .red
        default: return .gray
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(lens.verdict)
                .font(.title3)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(lens.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if isPrimary {
                        Text("YOUR GOAL")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                Text(lens.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(isPrimary ? Color.accentColor.opacity(0.08) : Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPrimary ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ScrollView {
        ResultsView(
            response: NutritionResponse(
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
            primaryGoal: "Fat Loss"
        )
        .padding()
    }
}

// ResultsView.swift
// nutrition_app

import SwiftUI

struct ResultsView: View {
    let response: NutritionResponse
    let primaryGoal: String
    var onAlternativeTap: ((String) -> Void)? = nil

    @State private var visibleCount = 0

    private var positiveCount: Int {
        response.lenses.filter { $0.verdict == "✅" }.count
    }

    private var scoreColor: Color {
        let ratio = Double(positiveCount) / Double(max(response.lenses.count, 1))
        if ratio >= 0.8 { return .green }
        if ratio >= 0.4 { return .orange }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Title + score badge
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Results for")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(response.food)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text("\(positiveCount)/\(response.lenses.count)")
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundStyle(scoreColor)
                    Text("positive")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(scoreColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Divider()

            // Summary paragraph
            if !response.summary.isEmpty {
                Text(response.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Lens cards — stagger in
            VStack(spacing: 10) {
                ForEach(Array(response.lenses.enumerated()), id: \.element.id) { index, lens in
                    if index < visibleCount {
                        LensCard(lens: lens, isPrimary: lens.name == primaryGoal)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .offset(y: 10)),
                                removal: .opacity
                            ))
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: visibleCount)

            // Alternatives — only on first-level results, not when already viewing an alternative
            if !response.alternatives.isEmpty && visibleCount >= response.lenses.count && onAlternativeTap != nil {
                alternativesSection
                    .transition(.opacity)
            }
        }
        .onAppear { staggerCards() }
    }

    // MARK: - Alternatives

    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Better alternatives for your goal", systemImage: "arrow.up.circle.fill")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(response.alternatives, id: \.self) { alt in
                    Button { onAlternativeTap?(alt) } label: {
                        alternativeRowLabel(alt: alt)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func alternativeRowLabel(alt: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.green)
            }
            Text(alt)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            Spacer()
            Text("Analyze")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 52)
        .background(Color.accentColor.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Stagger

    private func staggerCards() {
        visibleCount = 0
        for i in 0..<response.lenses.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.07) {
                visibleCount = i + 1
            }
        }
    }
}

// MARK: - LensCard

struct LensCard: View {
    let lens: LensResult
    let isPrimary: Bool

    private var verdictConfig: (color: Color, icon: String) {
        switch lens.verdict {
        case "✅": return (.green,  "checkmark.circle.fill")
        case "⚠️": return (.orange, "exclamationmark.triangle.fill")
        case "❌": return (.red,    "xmark.circle.fill")
        default:   return (.gray,   "questionmark.circle.fill")
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Colored left bar — instant visual scan of good/caution/avoid
            RoundedRectangle(cornerRadius: 2)
                .fill(verdictConfig.color)
                .frame(width: 4)
                .padding(.vertical, 4)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: verdictConfig.icon)
                    .font(.title3)
                    .foregroundStyle(verdictConfig.color)
                    .frame(width: 28, height: 28)

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
        }
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
                summary: "Eggs are one of the most well-rounded foods you can eat. They score well across nearly every lens, making them a reliable staple whether you're cutting, building muscle, or on a budget.",
                lenses: [
                    LensResult(name: "Fat Loss",             verdict: "✅", reason: "High protein, moderate calories — keeps you full and supports fat burning."),
                    LensResult(name: "Muscle Gain",          verdict: "✅", reason: "Complete protein with all essential amino acids, ideal for muscle synthesis."),
                    LensResult(name: "Whole Foods",          verdict: "✅", reason: "Minimally processed whole food packed with vitamins and healthy fats."),
                    LensResult(name: "Athletic Performance", verdict: "✅", reason: "Rich in choline and B vitamins that support energy metabolism and recovery."),
                    LensResult(name: "Budget",               verdict: "✅", reason: "One of the cheapest high-quality protein sources at roughly $0.20 per egg.")
                ],
                alternatives: ["Greek yogurt", "Cottage cheese", "Tuna"]
            ),
            primaryGoal: "Fat Loss"
        )
        .padding()
    }
}

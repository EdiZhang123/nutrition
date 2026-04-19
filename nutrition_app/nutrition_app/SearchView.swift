// SearchView.swift
// nutrition_app

import SwiftUI

struct SearchView: View {
    @AppStorage("userProfileData") private var userProfileData = Data()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var foodQuery = ""
    @State private var selectedGoal: HealthGoal = .fatLoss
    @State private var isLoading = false
    @State private var result: NutritionResponse?

    private var userProfile: UserProfile? {
        try? JSONDecoder().decode(UserProfile.self, from: userProfileData)
    }

    private let exampleFoods = ["Eggs", "White Rice", "Protein Bar", "Avocado", "Soda"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🥗 Nutrition Lens")
                            .font(.title2)
                            .fontWeight(.bold)
                        if let profile = userProfile, !profile.healthGoal.isEmpty {
                            Text("Profile goal: \(profile.healthGoal)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Food input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What food are you analyzing?")
                            .font(.headline)

                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                            TextField("e.g. eggs, white rice, protein bar…", text: $foodQuery)
                                .submitLabel(.search)
                                .onSubmit { analyze() }
                            if !foodQuery.isEmpty {
                                Button {
                                    foodQuery = ""
                                    result = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Goal picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Analyze through the lens of:")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(HealthGoal.allCases) { goal in
                                GoalChip(goal: goal, isSelected: selectedGoal == goal) {
                                    selectedGoal = goal
                                }
                            }
                        }
                    }

                    // Analyze button
                    Button(action: analyze) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 6)
                            }
                            Text(isLoading ? "Analyzing…" : "Analyze Food")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(foodQuery.isEmpty ? Color.secondary.opacity(0.4) : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(foodQuery.isEmpty || isLoading)

                    // Quick examples (hide after getting results)
                    if result == nil && !isLoading {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Try these:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(exampleFoods, id: \.self) { food in
                                        Button(food) {
                                            foodQuery = food
                                        }
                                        .buttonStyle(.bordered)
                                        .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }

                    // Results
                    if let result {
                        ResultsView(response: result, primaryGoal: selectedGoal.rawValue)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.3), value: result != nil)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Reset onboarding to allow profile editing
                        hasCompletedOnboarding = false
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
        }
    }

    private func analyze() {
        guard !foodQuery.isEmpty else { return }
        isLoading = true
        result = nil

        Task {
            let response = await NutritionService.shared.analyze(food: foodQuery, goal: selectedGoal.rawValue, profile: userProfile)
            await MainActor.run {
                withAnimation {
                    result = response
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - GoalChip

struct GoalChip: View {
    let goal: HealthGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: goal.icon)
                    .font(.caption)
                Text(goal.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchView()
}

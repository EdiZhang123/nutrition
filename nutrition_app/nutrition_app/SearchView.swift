// SearchView.swift
// nutrition_app

import SwiftUI

private enum ViewState {
    case idle
    case loading
    case success(NutritionResponse)
    case failure(String)
}

struct SearchView: View {
    @AppStorage("userProfileData") private var userProfileData = Data()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var foodQuery = ""
    @State private var selectedGoal: HealthGoal = .fatLoss
    @State private var viewState: ViewState = .idle
    @State private var isAlternativeResult = false
    @FocusState private var searchFocused: Bool

    private var userProfile: UserProfile? {
        try? JSONDecoder().decode(UserProfile.self, from: userProfileData)
    }

    private let exampleFoods = ["Eggs", "White Rice", "Protein Bar", "Avocado", "Soda"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerCard
                        searchSection
                        goalSection
                        analyzeButton
                        stateContent
                    }
                    .padding()
                    .animation(.easeInOut(duration: 0.25), value: stateTag)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        hasCompletedOnboarding = false
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { searchFocused = false }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var stateTag: Int {
        switch viewState {
        case .idle: return 0
        case .loading: return 1
        case .success: return 2
        case .failure: return 3
        }
    }

    // MARK: - State Content

    @ViewBuilder
    var stateContent: some View {
        switch viewState {
        case .idle:
            quickPicks
                .transition(.opacity)
        case .loading:
            SkeletonResultsView()
                .transition(.opacity)
        case .success(let response):
            ResultsView(
                response: response,
                primaryGoal: selectedGoal.rawValue,
                onAlternativeTap: isAlternativeResult ? nil : { food in
                    foodQuery = food
                    isAlternativeResult = true
                    analyzeFood(food)
                }
            )
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .bottom)),
                removal: .opacity
            ))
        case .failure(let message):
            errorView(message: message)
                .transition(.opacity)
        }
    }

    // MARK: - Header Card

    var headerCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("🥗 Nutrition Lens")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                if let profile = userProfile, !profile.healthGoal.isEmpty {
                    Label(profile.healthGoal, systemImage: "target")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.88))
                } else {
                    Text("Analyze any food instantly")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.88))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: [Color(hue: 0.35, saturation: 0.72, brightness: 0.58), .mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .green.opacity(0.25), radius: 12, y: 5)
    }

    // MARK: - Search

    var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What food are you analyzing?")
                .font(.headline)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("e.g. eggs, white rice, protein bar…", text: $foodQuery)
                    .submitLabel(.search)
                    .focused($searchFocused)
                    .onSubmit { analyze() }
                if !foodQuery.isEmpty {
                    Button {
                        foodQuery = ""
                        isAlternativeResult = false
                        withAnimation(.easeOut(duration: 0.2)) { viewState = .idle }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .padding(12)
            .frame(minHeight: 52)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        }
    }

    // MARK: - Goal Picker

    var goalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analyze through the lens of:")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(HealthGoal.allCases) { goal in
                    GoalChip(goal: goal, isSelected: selectedGoal == goal) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedGoal = goal
                        }
                    }
                }
            }
        }
    }

    // MARK: - Analyze Button

    private var isLoading: Bool {
        if case .loading = viewState { return true }
        return false
    }

    var analyzeButton: some View {
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
            .frame(minHeight: 52)
            .background(
                LinearGradient(
                    colors: foodQuery.isEmpty
                        ? [Color.secondary.opacity(0.4), Color.secondary.opacity(0.4)]
                        : [Color(hue: 0.35, saturation: 0.72, brightness: 0.58), .mint],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: foodQuery.isEmpty ? .clear : .green.opacity(0.3), radius: 8, y: 4)
            .animation(.easeInOut(duration: 0.2), value: foodQuery.isEmpty)
        }
        .disabled(foodQuery.isEmpty || isLoading)
    }

    // MARK: - Quick Picks

    var quickPicks: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try these:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(exampleFoods, id: \.self) { food in
                        Button(food) {
                            foodQuery = food
                            searchFocused = false
                        }
                        .buttonStyle(.bordered)
                        .font(.subheadline)
                        .frame(minHeight: 36)
                    }
                }
            }
        }
    }

    // MARK: - Error View

    func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.orange)
            VStack(spacing: 6) {
                Text("Couldn't load results")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button("Try Again") { analyze() }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Analyze

    private func analyze() {
        guard !foodQuery.isEmpty else { return }
        isAlternativeResult = false
        analyzeFood(foodQuery)
    }

    private func analyzeFood(_ food: String) {
        searchFocused = false
        withAnimation(.easeOut(duration: 0.2)) { viewState = .loading }

        Task {
            let response = await NutritionService.shared.analyze(food: food, goal: selectedGoal.rawValue, profile: userProfile)
            await MainActor.run {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    viewState = .success(response)
                }
            }
        }
    }
}

// MARK: - Skeleton Loading

struct SkeletonResultsView: View {
    @State private var pulsing = false

    private let cardWidths: [CGFloat] = [200, 220, 180, 235, 195]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                SkeletonBar(width: 76, height: 13)
                SkeletonBar(width: 148, height: 20)
            }
            .padding(.bottom, 4)

            Color(.separator).frame(height: 0.5).padding(.bottom, 4)

            ForEach(Array(cardWidths.enumerated()), id: \.offset) { _, reasonWidth in
                HStack(alignment: .top, spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray4))
                        .frame(width: 4)
                        .padding(.vertical, 4)

                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 24, height: 24)
                        VStack(alignment: .leading, spacing: 7) {
                            SkeletonBar(width: 88, height: 12)
                            SkeletonBar(width: reasonWidth, height: 10)
                        }
                        Spacer()
                    }
                    .padding(14)
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .opacity(pulsing ? 0.45 : 0.9)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                pulsing = true
            }
        }
    }
}

struct SkeletonBar: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: height / 2)
            .fill(Color(.systemGray5))
            .frame(width: width, height: height)
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
                    .foregroundStyle(isSelected ? .white : .accentColor)
                Text(goal.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .shadow(color: isSelected ? .accentColor.opacity(0.25) : .clear, radius: 5, y: 2)
    }
}

#Preview {
    SearchView()
}

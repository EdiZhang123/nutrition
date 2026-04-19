// OnboardingView.swift
// nutrition_app

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userProfileData") private var userProfileData = Data()

    @State private var ageRange = ""
    @State private var sex = ""
    @State private var heightFt = 5
    @State private var heightIn = 8
    @State private var weightLbs = 150
    @State private var lifestyle = ""
    @State private var healthGoal = ""
    @State private var currentStep = 0

    private let ageRanges = ["Under 18", "18–25", "26–35", "36–45", "46–55", "56–65", "65+"]
    private let lifestyles = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Athlete"]

    var body: some View {
        VStack(spacing: 0) {
            // Logo header
            VStack(spacing: 8) {
                Text("🥗")
                    .font(.system(size: 56))
                Text("Nutrition Lens")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Let's personalize your experience")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 48)
            .padding(.bottom, 32)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.accentColor)
                        .frame(width: geo.size.width * CGFloat(currentStep + 1) / 4, height: 4)
                        .animation(.easeInOut, value: currentStep)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
            .padding(.bottom, 32)

            // Step content
            ScrollView {
                VStack(spacing: 0) {
                    switch currentStep {
                    case 0: ageStep
                    case 1: statsStep
                    case 2: lifestyleStep
                    case 3: goalStep
                    default: EmptyView()
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Navigation buttons
            HStack(spacing: 12) {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation(.easeInOut) { currentStep -= 1 }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button(currentStep < 3 ? "Next" : "Get Started") {
                    if currentStep < 3 {
                        withAnimation(.easeInOut) { currentStep += 1 }
                    } else {
                        saveAndFinish()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .disabled(currentStepIsEmpty)
            }
            .padding()
        }
    }

    // MARK: - Steps

    private var ageStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(title: "How old are you?", subtitle: "Step 1 of 4 — We tailor advice to your age group")
            ForEach(ageRanges, id: \.self) { range in
                SelectionRow(title: range, isSelected: ageRange == range) { ageRange = range }
            }
        }
    }

    private var statsStep: some View {
        VStack(alignment: .leading, spacing: 28) {
            stepHeader(title: "Your body stats", subtitle: "Step 2 of 4 — Used to estimate your nutritional needs")

            // Sex
            VStack(alignment: .leading, spacing: 8) {
                Text("SEX")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .kerning(1)

                HStack(spacing: 10) {
                    ForEach(["Male", "Female", "Prefer not to say"], id: \.self) { option in
                        Button {
                            sex = option
                        } label: {
                            Text(option)
                                .font(.subheadline)
                                .fontWeight(sex == option ? .semibold : .regular)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(sex == option ? Color.accentColor : Color(.secondarySystemBackground))
                                .foregroundStyle(sex == option ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Height
            VStack(alignment: .leading, spacing: 8) {
                Text("HEIGHT")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .kerning(1)

                ZStack {
                    // Selection band
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemBackground))
                        .frame(height: 44)

                    HStack(spacing: 0) {
                        Picker("Feet", selection: $heightFt) {
                            ForEach(4...7, id: \.self) { ft in
                                Text("\(ft) ft")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .tag(ft)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()

                        Picker("Inches", selection: $heightIn) {
                            ForEach(0...11, id: \.self) { inch in
                                Text("\(inch) in")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .tag(inch)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .frame(height: 180)
            }

            // Weight
            VStack(alignment: .leading, spacing: 8) {
                Text("WEIGHT")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .kerning(1)

                VStack(spacing: 16) {
                    // Current value display
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(weightLbs)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .animation(.snappy, value: weightLbs)
                        Text("lbs")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    // Slider
                    VStack(spacing: 6) {
                        Slider(value: Binding(
                            get: { Double(weightLbs) },
                            set: { weightLbs = Int($0) }
                        ), in: 80...400, step: 1)
                        .tint(.accentColor)

                        HStack {
                            Text("80")
                            Spacer()
                            Text("400")
                        }
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    }
                }
                .padding(20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var lifestyleStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(title: "Your lifestyle", subtitle: "Step 3 of 4 — How active are you day-to-day?")
            ForEach(lifestyles, id: \.self) { ls in
                SelectionRow(title: ls, isSelected: lifestyle == ls) { lifestyle = ls }
            }
        }
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(title: "Primary goal", subtitle: "Step 4 of 4 — We'll highlight this lens in your results")
            ForEach(HealthGoal.allCases) { goal in
                SelectionRow(title: goal.rawValue, icon: goal.icon, isSelected: healthGoal == goal.rawValue) {
                    healthGoal = goal.rawValue
                }
            }
        }
    }

    // MARK: - Helpers

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 4)
    }

    private var currentStepIsEmpty: Bool {
        switch currentStep {
        case 0: return ageRange.isEmpty
        case 1: return sex.isEmpty
        case 2: return lifestyle.isEmpty
        case 3: return healthGoal.isEmpty
        default: return false
        }
    }

    private func saveAndFinish() {
        let profile = UserProfile(
            ageRange: ageRange,
            sex: sex,
            height: "\(heightFt)'\(heightIn)\"",
            weight: "\(weightLbs)",
            lifestyle: lifestyle,
            healthGoal: healthGoal
        )
        if let data = try? JSONEncoder().encode(profile) {
            userProfileData = data
        }
        hasCompletedOnboarding = true
    }
}

// MARK: - SelectionRow

struct SelectionRow: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(isSelected ? .white : .accentColor)
                        .frame(width: 24)
                }
                Text(title)
                    .fontWeight(isSelected ? .semibold : .regular)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Step 1 — Age") {
    OnboardingView()
}

#Preview("Step 2 — Height & Weight") {
    // Show the pickers directly for quick review
    ScrollView {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your body stats")
                    .font(.title2).fontWeight(.semibold)
                Text("Step 2 of 4 — Used to estimate your nutritional needs")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("HEIGHT").font(.caption).fontWeight(.semibold).foregroundStyle(.secondary).kerning(1)
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground)).frame(height: 44)
                    HStack(spacing: 0) {
                        Picker("Feet", selection: .constant(5)) {
                            ForEach(4...7, id: \.self) { ft in Text("\(ft) ft").font(.title3).fontWeight(.medium).tag(ft) }
                        }.pickerStyle(.wheel).frame(maxWidth: .infinity).clipped()
                        Picker("Inches", selection: .constant(8)) {
                            ForEach(0...11, id: \.self) { inch in Text("\(inch) in").font(.title3).fontWeight(.medium).tag(inch) }
                        }.pickerStyle(.wheel).frame(maxWidth: .infinity).clipped()
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .frame(height: 180)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("WEIGHT").font(.caption).fontWeight(.semibold).foregroundStyle(.secondary).kerning(1)
                VStack(spacing: 16) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("150").font(.system(size: 52, weight: .bold, design: .rounded))
                        Text("lbs").font(.title3).fontWeight(.medium).foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity)
                    VStack(spacing: 6) {
                        Slider(value: .constant(150), in: 80...400, step: 1).tint(.accentColor)
                        HStack { Text("80"); Spacer(); Text("400") }.font(.caption).foregroundStyle(.tertiary)
                    }
                }
                .padding(20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding()
    }
}

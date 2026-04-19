//
//  ContentView.swift
//  nutrition_app
//
//  Created by Edi Zhang on 4/19/26.
//

// ContentView.swift
// nutrition_app — Root router

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            SearchView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}

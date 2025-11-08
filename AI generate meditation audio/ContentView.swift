//
//  ContentView.swift
//  AI generate meditation audio
//
//  Created by Alicia Tu on 2025/11/7.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        NavigationStack {
            OnboardingView()
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    ContentView()
}

//
//  OnboardingView.swift
//  AI generate meditation audio
//
//  Created by Assistant.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var navigateToScript: Bool = false
    
    private let goals = ["减压", "睡眠", "专注", "情绪"]
    private let durations = [5, 10, 15, 20]
    private let periods = ["早晨", "午间", "晚上"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemTeal), Color(.systemIndigo)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("AI 冥想")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                    Text("根据你的目标与习惯，生成专属冥想脚本")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 24)
                
                // Progress dots
                HStack(spacing: 8) {
                    Circle().fill(selectionFilled(viewModel.goal)).frame(width: 8, height: 8)
                    Circle().fill(selectionFilled(viewModel.durationMinutes)).frame(width: 8, height: 8)
                    Circle().fill(selectionFilled(viewModel.dayPeriod)).frame(width: 8, height: 8)
                }
                .opacity(0.9)
                
                ScrollView {
                    VStack(spacing: 16) {
                        questionCard(title: "你的冥想目标", subtitle: "请选择一项", content: {
                            wrapChips(goals, selection: Binding(
                                get: { viewModel.goal ?? "" },
                                set: { viewModel.goal = $0 }
                            ))
                        })
                        
                        questionCard(title: "单次时长（分钟）", subtitle: "请选择一项", content: {
                            wrapChips(durations.map { "\($0)" }, selection: Binding(
                                get: { viewModel.durationMinutes.map(String.init) ?? "" },
                                set: { viewModel.durationMinutes = Int($0) }
                            ))
                        })
                        
                        questionCard(title: "你更喜欢在什么时候冥想", subtitle: "请选择一项", content: {
                            wrapChips(periods, selection: Binding(
                                get: { viewModel.dayPeriod ?? "" },
                                set: { viewModel.dayPeriod = $0 }
                            ))
                        })
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                
                NavigationLink(isActive: $navigateToScript) {
                    ScriptView()
                        .environmentObject(viewModel)
                } label: { EmptyView() }
                .hidden()
                
                Button {
                    Task {
                        await viewModel.generateScript()
                        navigateToScript = true
                    }
                } label: {
                    HStack {
                        if viewModel.isGenerating {
                            ProgressView().tint(.white)
                        }
                        Text(viewModel.isGenerating ? "正在生成..." : "生成脚本")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canGenerate() ? Color.white.opacity(0.15) : Color.white.opacity(0.08))
                    .foregroundStyle(.white)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .disabled(!viewModel.canGenerate() || viewModel.isGenerating)
            }
        }
    }
    
    // MARK: - Helpers
    private func selectionFilled<T>(_ value: T?) -> Color {
        value == nil ? .white.opacity(0.35) : .white
    }
    
    @ViewBuilder
    private func questionCard<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline).foregroundStyle(.white)
            Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.9))
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func wrapChips(_ items: [String], selection: Binding<String>) -> some View {
        FlexibleChips(items: items, selection: selection)
    }
}

// MARK: - Flexible Chips
private struct FlexibleChips: View {
    let items: [String]
    @Binding var selection: String
    
    @State private var totalHeight: CGFloat = .zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func chip(for text: String) -> some View {
        let selected = selection == text
        return Button {
            selection = text
        } label: {
            Text(text)
                .font(.subheadline).bold()
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(selected ? Color.white.opacity(0.9) : Color.white.opacity(0.15))
                .foregroundStyle(selected ? Color.black : Color.white)
                .cornerRadius(22)
        }
        .buttonStyle(.plain)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                chip(for: item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if width + d.width > g.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == items.last! {
                            width = 0
                        } else {
                            width += d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item == items.last! {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(
            GeometryReader { inner in
                Color.clear.onAppear {
                    totalHeight = inner.size.height
                }.onChange(of: inner.size.height) { _, newValue in
                    totalHeight = newValue
                }
            }
        )
    }
}



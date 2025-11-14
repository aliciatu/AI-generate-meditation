//
//  GeneratingView.swift
//  AI generate meditation audio
//
//  Created by Assistant.
//

import SwiftUI

struct GeneratingView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var animateOuter = false
    @State private var animateMiddle = false
    @State private var progressWidth: CGFloat = 0
    @State private var floatingPhase: Double = 0
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // Background soft blobs
            ZStack {
                Circle()
                    .fill(DS.accentYellow.opacity(0.12))
                    .frame(width: 220, height: 220)
                    .blur(radius: 48)
                    .offset(x: 120, y: -140)
                Circle()
                    .fill(DS.accentGreen.opacity(0.12))
                    .frame(width: 220, height: 220)
                    .blur(radius: 48)
                    .offset(x: -120, y: 160)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 28) {
                // Mascot with halos
                ZStack {
                    Circle()
                        .stroke(DS.accentYellow, lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .opacity(0.3)
                        .scaleEffect(animateOuter ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: animateOuter)
                    Circle()
                        .stroke(DS.accentGreen, lineWidth: 2)
                        .frame(width: 150, height: 150)
                        .opacity(0.4)
                        .scaleEffect(animateMiddle ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.2), value: animateMiddle)
                    
                    // Body+Head blob
                    VStack(spacing: 0) {
                        Circle()
                            .fill(Color(hex: "#7B6AFF"))
                            .frame(width: 96, height: 96)
                            .overlay(
                                Circle()
                                    .fill(
                                        RadialGradient(colors: [Color.white.opacity(0.18), .clear], center: .center, startRadius: 0, endRadius: 48)
                                    )
                            )
                        Ellipse()
                            .fill(Color(hex: "#5B4CFF"))
                            .frame(width: 120, height: 64)
                            .offset(y: -10)
                    }
                    .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 10)
                    
                    // Eyes and smile
                    VStack(spacing: 6) {
                        HStack(spacing: 18) {
                            eye
                            eye
                        }
                        .offset(y: -10)
                        smile
                            .offset(y: -6)
                    }
                }
                .frame(height: 220)
                
                VStack(spacing: 8) {
                    Text("正在为你定制冥想...")
                        .font(.title3).bold()
                        .foregroundStyle(Color(hex: "#1F2937"))
                    Text("AI 正在根据你的答案创造独特体验")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "#6B7280"))
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: "#E5E7EB")).frame(height: 8)
                    Capsule().fill(
                        LinearGradient(colors: [DS.accentYellow, DS.accentGreen, DS.accentPink], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: progressWidth, height: 8)
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: progressWidth)
                }
                .frame(maxWidth: 260)
                
                // Rotating tip
                Text("💭 \(tipText)")
                    .font(.callout)
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                    .frame(height: 22)
                
                Spacer(minLength: 0)
            }
            .padding(.top, 80)
            .padding(.bottom, 40)
            
            // Floating icons
            floatingIcon("✨", x: -120, y: -260, phase: 0)
            floatingIcon("🌙", x: 130, y: 260, phase: 0.4)
            floatingIcon("⭐", x: 150, y: 0, phase: 0.8)
        }
        .onAppear {
            animateOuter = true
            animateMiddle = true
            progressWidth = 1 // kick off animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                floatingPhase = 1
            }
        }
    }
    
    private var eye: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: 16, y: 0), control: CGPoint(x: 8, y: 4))
        }
        .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
        .frame(width: 16, height: 6)
        .opacity(0.9)
        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: animateOuter)
    }
    
    private var smile: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 6))
            path.addQuadCurve(to: CGPoint(x: 36, y: 6), control: CGPoint(x: 18, y: 14))
        }
        .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        .frame(width: 36, height: 16)
        .opacity(0.95)
    }
    
    private var tipText: String {
        let tips = [
            "深呼吸，感受当下",
            "放松你的肩膀",
            "让思绪自由流动",
            "专注于你的呼吸"
        ]
        return tips[min(viewModel.loadingTipIndex, tips.count - 1)]
    }
    
    @ViewBuilder
    private func floatingIcon(_ text: String, x: CGFloat, y: CGFloat, phase: Double) -> some View {
        let offsetAnim = sin((floatingPhase + phase) * .pi * 2) * 10
        Text(text)
            .font(.system(size: text == "✨" ? 28 : text == "🌙" ? 26 : 22))
            .opacity(0.6)
            .offset(x: x, y: y + offsetAnim)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(phase), value: floatingPhase)
    }
}




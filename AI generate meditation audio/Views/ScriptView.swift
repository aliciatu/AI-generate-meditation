//
//  ScriptView.swift
//  AI generate meditation audio
//
//  Created by Assistant.
//

import SwiftUI

struct ScriptView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var isPlaying: Bool = false
    @State private var pulse = false
    @State private var showVoices = false
    
    var body: some View {
        ZStack {
            DS.brandGradient
            .ignoresSafeArea()
            
            VStack(spacing: 18) {
                header
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            Text("你的专属冥想")
                                .font(.title2).bold()
                                .foregroundStyle(Color(hex: "#1F2937"))
                            Text("AI 生成引导 · 背景音乐可调")
                                .font(.subheadline)
                                .foregroundStyle(Color(hex: "#6B7280"))
                        }
                        .padding(.top, 6)
                        
                        Text(viewModel.generatedScript.isEmpty ? "脚本尚未生成" : viewModel.generatedScript)
                            .font(.body)
                            .foregroundStyle(Color(hex: "#374151"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                LinearGradient(colors: [Color(hex: "#F9FAFB"), Color(hex: "#F3F4F6").opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(DS.cardBorder, lineWidth: 1)
                            )
                    }
                    .padding(18)
                    .background(DS.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DS.containerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.containerRadius, style: .continuous)
                            .stroke(DS.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                    .padding(.horizontal, 18)
                }
                
                VStack(spacing: 16) {
                    // Big play/pause
                    Button {
                        togglePlay()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: 140, height: 140)
                                .scaleEffect(isPlaying ? (pulse ? 1.08 : 0.96) : 1.0)
                                .animation(isPlaying ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true) : .default, value: pulse)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(24)
                                .background(
                                    LinearGradient(colors: [Color(hex: "#5B4CFF"), Color(hex: "#7B6AFF")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color(hex: "#7B6AFF").opacity(0.4), radius: 16, x: 0, y: 8)
                                .scaleEffect(isPlaying ? 1.02 : 1.0)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: Binding(get: { viewModel.isMusicOn }, set: { viewModel.toggleMusic($0) })) {
                            Text("背景音乐").foregroundStyle(.white)
                        }
                        HStack {
                            Image(systemName: "speaker.fill").foregroundStyle(.white.opacity(0.9))
                            Slider(value: Binding(
                                get: { Double(viewModel.musicVolume) },
                                set: { viewModel.setMusicVolume(Float($0)) }
                            ), in: 0...1)
                            .tint(DS.accentPink)
                            Image(systemName: "speaker.wave.3.fill").foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .padding(16)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                
                HStack(spacing: 12) {
                    NavigationLink {
                        OnboardingView().environmentObject(viewModel)
                    } label: {
                        Text("返回修改")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .foregroundStyle(.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    }
                    
                    Button {
                        Task { await viewModel.generateScript() }
                    } label: {
                        Text("重新生成")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("列出语音") {
                    viewModel.dumpAvailableVoices()
                    showVoices = true
                }
                .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $showVoices) {
            NavigationStack {
                ScrollView {
                    Text(viewModel.debugVoicesDump.isEmpty ? "无可用语音列表，请重试。" : viewModel.debugVoicesDump)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                }
                .navigationTitle("可用语音")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("完成") { showVoices = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .onChange(of: isPlaying) { _, newValue in
            if newValue {
                pulse.toggle()
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 6) {
            Text("享受这段专属时光")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.top, 14)
    }
    
    private func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            viewModel.speakScript()
        } else {
            viewModel.stopSpeaking()
        }
    }
}


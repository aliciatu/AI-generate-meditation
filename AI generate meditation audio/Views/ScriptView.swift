//
//  ScriptView.swift
//  AI generate meditation audio
//
//  Created by Assistant.
//

import SwiftUI

struct ScriptView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemIndigo), Color(.systemTeal)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("你的专属冥想")
                        .font(.title).bold()
                        .foregroundStyle(.white)
                    Text("可以直接收听，或调整背景音乐音量")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(.top, 16)
                
                ScrollView {
                    Text(viewModel.generatedScript.isEmpty ? "脚本尚未生成" : viewModel.generatedScript)
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.black.opacity(0.15))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                }
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button {
                            viewModel.speakScript()
                        } label: {
                            label(icon: "play.fill", title: "播放")
                        }
                        Button {
                            viewModel.stopSpeaking()
                        } label: {
                            label(icon: "stop.fill", title: "停止")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: Binding(get: { viewModel.isMusicOn }, set: { viewModel.toggleMusic($0) })) {
                            Text("背景音乐")
                                .foregroundStyle(.white)
                        }
                        HStack {
                            Image(systemName: "speaker.fill").foregroundStyle(.white.opacity(0.9))
                            Slider(value: Binding(
                                get: { Double(viewModel.musicVolume) },
                                set: { viewModel.setMusicVolume(Float($0)) }
                            ), in: 0...1)
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
    }
    
    private func label(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.headline)
            Text(title).bold()
        }
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



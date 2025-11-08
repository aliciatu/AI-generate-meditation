//
//  AppViewModel.swift
//  AI generate meditation audio
//
//  Created by Assistant.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

final class AppViewModel: NSObject, ObservableObject {
    // MARK: - User Selections
    @Published var goal: String? = nil
    @Published var durationMinutes: Int? = nil
    @Published var dayPeriod: String? = nil
    
    // MARK: - Generation
    @Published var isGenerating: Bool = false
    @Published var generatedScript: String = ""
    
    // MARK: - Speech
    private let speechSynthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking: Bool = false
    
    // MARK: - Background Music
    private var backgroundPlayer: AVAudioPlayer?
    @Published var isMusicOn: Bool = true
    @Published var musicVolume: Float = 0.3
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
        configureAudioSession()
        prepareBackgroundPlayer()
    }
    
    // MARK: - Public API
    func canGenerate() -> Bool {
        goal != nil && durationMinutes != nil && dayPeriod != nil
    }
    
    @MainActor
    func generateScript() async {
        guard canGenerate(), let goal, let durationMinutes, let dayPeriod else { return }
        isGenerating = true
        defer { isGenerating = false }
        
        // TODO: Replace with real LLM call. For now, generate a tailored template.
        // Simulate minimal latency for UX.
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        let intro = "欢迎来到你的专属冥想练习。"
        let focusLine: String
        switch goal {
        case "减压":
            focusLine = "我们将用温和的呼吸，释放肩颈与胸口的紧张。"
        case "睡眠":
            focusLine = "让身体逐渐松弛，把注意力放在温柔而缓慢的呼吸上。"
        case "专注":
            focusLine = "把意识轻轻带回当下，锚定在自然的吸气与呼气之间。"
        case "情绪":
            focusLine = "以接纳的姿态与情绪同在，让它自然来去，如云般漂浮。"
        default:
            focusLine = "我们将以平稳的呼吸与温柔的觉察，陪伴此刻的身心变化。"
        }
        
        let timeHint = "本次练习约 \(durationMinutes) 分钟，适合在\(dayPeriod)进行。"
        let body = """
        先找到一个舒适的姿势，轻轻闭上眼睛。吸气时感受空气进入身体，呼气时让身心缓缓放松。
        如果思绪飘走，就温柔地把注意力带回呼吸，不批判，不着急。
        随着每一次呼吸，你会感到更安定、更清晰。
        """
        let outro = "在结束前，向自己表达感谢：感谢你为身心预留这段温柔的时间。"
        
        self.generatedScript = [intro, focusLine, timeHint, body, outro].joined(separator: "\n\n")
    }
    
    func speakScript() {
        guard !generatedScript.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: generatedScript)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    func toggleMusic(_ on: Bool) {
        isMusicOn = on
        if on {
            if backgroundPlayer == nil {
                prepareBackgroundPlayer()
            }
            backgroundPlayer?.volume = musicVolume
            backgroundPlayer?.play()
        } else {
            backgroundPlayer?.stop()
        }
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = volume
        backgroundPlayer?.volume = volume
    }
    
    // MARK: - Private Helpers
    private func configureAudioSession() {
        // Ambient allows mixing with other audio and is suitable for meditation background music.
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Silent fail is acceptable for prototype
        }
    }
    
    private func prepareBackgroundPlayer() {
        // Expect a bundled file named "meditation_bg.mp3". If missing, we keep player nil gracefully.
        guard let url = Bundle.main.url(forResource: "meditation_bg", withExtension: "mp3") else {
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = musicVolume
            player.prepareToPlay()
            backgroundPlayer = player
            if isMusicOn {
                player.play()
            }
        } catch {
            backgroundPlayer = nil
        }
    }
}

extension AppViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = true }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
}



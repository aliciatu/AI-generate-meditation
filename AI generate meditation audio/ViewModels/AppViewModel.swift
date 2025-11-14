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
    
    // MARK: - New Sequential Questions
    // 1) 你今天最想完成的事情是什么？
    @Published var todayObjective: String = ""
    // 2) 你理想的一天是什么样？
    @Published var idealDay: String = ""
    // 3) 今天最想养成的习惯是什么？
    @Published var todayHabit: String = ""
    // 4) 今天的冥想基调是什么？（平静 / self love / 睿智）
    @Published var meditationTone: String = ""
    
    // MARK: - Generation
    @Published var isGenerating: Bool = false
    @Published var generatedScript: String = ""
    @Published var loadingTipIndex: Int = 0
    @Published var debugVoicesDump: String = ""
    
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
        !todayObjective.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !idealDay.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !todayHabit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !meditationTone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @MainActor
    func generateScript() async {
        guard canGenerate() else { return }
        isGenerating = true
        defer { isGenerating = false }
        
        // TODO: Replace with real LLM call. For now, generate a tailored template.
        // Simulate minimal latency for UX.
        for i in 0..<6 {
            loadingTipIndex = i % 4
            try? await Task.sleep(nanoseconds: 150_000_000)
        }
        
        let intro = "欢迎来到你的专属冥想练习。找到一个舒适的姿势，轻轻闭上眼睛。"
        
        let toneLine: String
        switch meditationTone.lowercased() {
        case "平静":
            toneLine = "今天的基调是“平静”。让呼吸像湖面一样安稳，轻轻抚平心中的波纹。"
        case "self love", "selflove", "自爱":
            toneLine = "今天的基调是“Self Love”。以温柔的态度看待自己，允许不完美，并用关怀对自己说：我已足够。"
        case "睿智":
            toneLine = "今天的基调是“睿智”。在呼吸之间生长清明，像晨光一样为当下带来洞见。"
        default:
            toneLine = "让呼吸带来安定与清澈，你会在过程中自然找到属于今天的节奏。"
        }
        
        let objective = todayObjective.trimmingCharacters(in: .whitespacesAndNewlines)
        let ideal = idealDay.trimmingCharacters(in: .whitespacesAndNewlines)
        let habit = todayHabit.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let focusGoal = "今天你最想完成的事情是：\(objective)。想象自己从容地迈出一步步，直到完整而踏实地完成它。"
        let idealVision = "你理想的一天是这样的：\(ideal)。让这幅画面在心中展开，感受其中的秩序、节奏与轻松。"
        let habitAnchor = "今天想要培养的习惯是：\(habit)。让它成为你在纷扰中回到当下的小锚点。"
        
        let breathing = """
        现在，跟随呼吸。吸气，觉察胸口的扩张；呼气，允许肩颈与额头进一步放松。
        若思绪飘走，就温柔地把注意力带回呼吸；不批判，不急躁，只是回来。
        """
        let outro = "在结束前，向自己表达感谢：感谢你为身心预留这段温柔的时间。带着这份清明与稳定，开启今天的行动。"
        
        self.generatedScript = [
            intro,
            toneLine,
            focusGoal,
            idealVision,
            habitAnchor,
            breathing,
            outro
        ].joined(separator: "\n\n")
    }
    
    func speakScript() {
        guard !generatedScript.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: generatedScript)
        // Prefer Siri Chinese voice (Voice 1) if available; fallback to zh-CN default
        if let siri = preferredChineseSiriVoice() {
            utterance.voice = siri
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        }
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
    private func preferredChineseSiriVoice() -> AVSpeechSynthesisVoice? {
        // 1) Try well-known Siri Chinese identifiers (female Voice 1 first)
        let candidateIds = [
            // Female (Voice 1) – premium/enhanced/compact variants
            "com.apple.ttsbundle.Siri_female_zh-CN_premium",
            "com.apple.ttsbundle.Siri_female_zh-CN_enhanced",
            "com.apple.ttsbundle.Siri_female_zh-CN_compact",
            "com.apple.ttsbundle.Siri_female_zh-CN",
            "com.apple.ttsbundle.siri_female_zh-CN_compact",
            // Male variants (fallback)
            "com.apple.ttsbundle.Siri_male_zh-CN_premium",
            "com.apple.ttsbundle.Siri_male_zh-CN_enhanced",
            "com.apple.ttsbundle.Siri_male_zh-CN_compact",
            "com.apple.ttsbundle.Siri_male_zh-CN"
        ]
        for id in candidateIds {
            if let v = AVSpeechSynthesisVoice(identifier: id) { return v }
        }
        
        // 2) Dynamic scan for any installed Chinese Siri voice
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let zhVoices = voices.filter { v in
            v.language.hasPrefix("zh") || v.language.hasPrefix("zh-CN") || v.language.hasPrefix("zh-Hans")
        }
        // Prefer Siri + female + premium/enhanced
        if let v = zhVoices.first(where: { v in
            (v.name.localizedCaseInsensitiveContains("Siri") || v.identifier.localizedCaseInsensitiveContains("Siri")) &&
            (v.identifier.localizedCaseInsensitiveContains("female") || v.name.localizedCaseInsensitiveContains("female")) &&
            (v.identifier.localizedCaseInsensitiveContains("premium") || v.identifier.localizedCaseInsensitiveContains("enhanced"))
        }) { return v }
        // Any Chinese Siri voice
        if let v = zhVoices.first(where: { v in
            v.name.localizedCaseInsensitiveContains("Siri") || v.identifier.localizedCaseInsensitiveContains("Siri")
        }) { return v }
        
        // 3) Fallback to any Mandarin voice
        return zhVoices.first
    }
    
    // MARK: - Debug: List available system TTS voices
    func dumpAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let lines: [String] = voices
            .sorted { (a, b) in
                if a.language != b.language { return a.language < b.language }
                return a.name < b.name
            }
            .map { v in
                let q = voiceQualityString(v)
                return "[\(v.language)] name=\(v.name) | id=\(v.identifier) | quality=\(q)"
            }
        let header = "Installed AVSpeech voices (\(voices.count)):"
        let dumpText = ([header] + lines).joined(separator: "\n")
        print(dumpText)
        debugVoicesDump = dumpText
    }
    
    private func voiceQualityString(_ v: AVSpeechSynthesisVoice) -> String {
        if #available(iOS 13.0, *) {
            switch v.quality {
            case .enhanced: return "enhanced"
            default: return "default"
            }
        } else {
            return "n/a"
        }
    }
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



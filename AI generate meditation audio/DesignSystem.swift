//
//  DesignSystem.swift
//  AI generate meditation audio
//
//  Created by Assistant.
//

import SwiftUI

enum DS {
    // Brand gradient from web UI: #5B4CFF → #6B5AFF → #7B6AFF
    static let brandGradient = LinearGradient(
        colors: [
            Color(hex: "#5B4CFF"),
            Color(hex: "#6B5AFF"),
            Color(hex: "#7B6AFF")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Accent colors from web UI
    static let accentYellow = Color(hex: "#FFD93D")
    static let accentGreen = Color(hex: "#6BCB77")
    static let accentPink = Color(hex: "#FF6B9D")
    
    // Container radius used widely in reference
    static let containerRadius: CGFloat = 28
    
    // Neutral surfaces
    static let cardBackground = Color.white
    static let cardBorder = Color(white: 0.95)
}

extension Color {
    init(hex: String) {
        let r, g, b, a: CGFloat
        var hexColor = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexColor.hasPrefix("#") { hexColor.removeFirst() }
        
        var rgba: UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&rgba)
        switch hexColor.count {
        case 6:
            r = CGFloat((rgba & 0xFF0000) >> 16) / 255
            g = CGFloat((rgba & 0x00FF00) >> 8) / 255
            b = CGFloat(rgba & 0x0000FF) / 255
            a = 1
        case 8:
            r = CGFloat((rgba & 0xFF000000) >> 24) / 255
            g = CGFloat((rgba & 0x00FF0000) >> 16) / 255
            b = CGFloat((rgba & 0x0000FF00) >> 8) / 255
            a = CGFloat(rgba & 0x000000FF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self = Color(red: r, green: g, blue: b, opacity: a)
    }
}




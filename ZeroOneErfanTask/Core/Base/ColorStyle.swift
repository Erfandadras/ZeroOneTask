//
//  ColorStyle.swift
//  realstate
//
//  Created by Erfan mac mini on 11/10/24.
//

import SwiftUI
import BaseModule


extension ColorStyle {
    static let red: Color = .adaptive(
        light: Color.red,
        dark: Color.red
    )
    
    /// Dynamic text color - high contrast in both modes
    public static let textPrimary: Color = .adaptive(
        light: Color(hex: "#000000"),
        dark: Color(hex: "#FFFFFF")
    )
    
    /// Dynamic text color - medium contrast
    public static let textSecondary: Color = .adaptive(
        light: Color(hex: "#6B7280"),
        dark: Color(hex: "#9CA3AF")
    )
    
    /// Dynamic background with subtle difference
    public static let cardBackground: Color = .adaptive(
        light: Color(hex: "#FFFFFF"),
        dark: Color(hex: "#1F2937")
    )
    
    
    /// Dynamic Blue
    public static let blue: Color = .adaptive(
        light: .blue,
        dark: .blue
    )
    
    /// Dynamic yellow
    public static let yellow: Color = .adaptive(
        light: .yellow,
        dark: .yellow
    )
    
    /// Dynamic gray
    public static let gray: Color = .adaptive(
        light: .gray,
        dark: .gray
    )
    
    
    /// Dynamic black
    public static let black: Color = .adaptive(
        light: .black,
        dark: .white
    )
}

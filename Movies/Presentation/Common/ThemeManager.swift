//
//  ThemeManager.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

enum AppTheme: Int {
    case light = 0
    case dark = 1

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var opposite: AppTheme {
        switch self {
        case .light: return .dark
        case .dark: return .light
        }
    }
}

final class ThemeManager {
    private enum Constants {
        static let storageKey = "app_theme_preference"
    }

    private let defaults: UserDefaults
    private(set) var currentTheme: AppTheme {
        didSet {
            defaults.set(currentTheme.rawValue, forKey: Constants.storageKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let storedValue = defaults.object(forKey: Constants.storageKey) as? Int,
           let storedTheme = AppTheme(rawValue: storedValue) {
            currentTheme = storedTheme
        } else {
            currentTheme = .light
            defaults.set(currentTheme.rawValue, forKey: Constants.storageKey)
        }
    }

    func toggleTheme() -> AppTheme {
        currentTheme = currentTheme.opposite
        return currentTheme
    }
}

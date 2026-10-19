// FoxTerm | Bundle.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation

public extension Bundle {
    /// 获取当前应用的显示名称
    /// 优先读取 `CFBundleDisplayName`，若不存在则退回读取 `CFBundleName`
    static var appName: String {
        let localizedInfo = Bundle.main.localizedInfoDictionary
        if let displayName = localizedInfo?["CFBundleDisplayName"] as? String {
            return displayName
        }
        if let bundleName = localizedInfo?[kCFBundleNameKey as String] as? String {
            return bundleName
        }
        let info = Bundle.main.infoDictionary
        if let displayName = info?["CFBundleDisplayName"] as? String {
            return displayName
        }
        if let bundleName = info?[kCFBundleNameKey as String] as? String {
            return bundleName
        }

        return ""
    }

    /// 获取当前应用的版本号
    /// macOS 平台读取短版本号(`CFBundleShortVersionString`)，其他平台(如 iOS/tvOS/watchOS)读取构建版本号(`CFBundleVersion`)
    static var currentAppVersion: String {
        #if os(macOS)
            let infoDictionaryKey = "CFBundleShortVersionString"
        #else
            let infoDictionaryKey = "CFBundleVersion"
        #endif
        return Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String ?? ""
    }

    static var langs: [String] {
        Bundle.main.localizations.filter { $0 != "Base" }
    }

    static var appVersionMarketing: String {
        if let name = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            name
        } else {
            ""
        }
    }

    static var appVersionBuild: String {
        let bundleKey = kCFBundleVersionKey as String
        if let version = Bundle.main.object(forInfoDictionaryKey: bundleKey) as? String {
            return version
        } else {
            return "0"
        }
    }

    static var isZhHans: Bool {
        guard let preferredLanguage = Locale.preferredLanguages.first else { return false }
        return preferredLanguage.hasPrefix("zh-Hans")
    }
}

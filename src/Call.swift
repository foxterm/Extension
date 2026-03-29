// FoxTerm | Call.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation

public class Call {
    let waitGroup: WaitGroup = .init()
    public static let shared: Call = .init()

    public init() {}
}

public extension Call {
    func callback<T>(_ callback: @escaping () -> T) async -> T {
        await withUnsafeContinuation { continuation in
            let ret = waitGroup.with {
                callback()
            }
            continuation.resume(returning: ret)
        }
    }

    func callback<T>(_ callback: @escaping () async -> T) async -> T {
        await withUnsafeContinuation { continuation in
            let ret = waitGroup.with {
                Task {
                    await callback()
                }
            }
            continuation.resume(returning: ret as! T)
        }
    }

    func callback<T>(_ callback: @escaping () -> T) -> T {
        waitGroup.with {
            callback()
        }
    }
}

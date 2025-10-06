//
//  RetryPolicy.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

enum RetryPolicy {
    static func execute<T>(
        times: Int,
        initialDelay: TimeInterval = 0.5,
        backoff: Double = 2.0,
        jitter: TimeInterval = 0.1,
        shouldRetry: @escaping (Error) -> Bool,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var attempt = 0
        var delay = initialDelay
        while true {
            do {
                return try await operation()
            } catch {
                attempt += 1
                if attempt > times || !shouldRetry(error) { throw error }
                let jitterDelta = (Double.random(in: -1...1) * jitter)
                let sleep = max(0, delay + jitterDelta)
                try? await Task.sleep(nanoseconds: UInt64(sleep * 1_000_000_000))
                delay *= backoff
            }
        }
    }
}

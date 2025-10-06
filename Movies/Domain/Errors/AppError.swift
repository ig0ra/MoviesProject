//
//  AppError.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

enum NetworkError: Equatable {
    case offline
    case timeout
    case connectionLost
    case dns
    case tls
    case rateLimited(retryAfter: TimeInterval?)
}

enum AppError: Error {
    case network(NetworkError)
    case server(status: Int, message: String?)
    case decoding(underlying: Error)
    case dataStore(underlying: Error)
    case config(message: String)
    case cancelled
    case unknown(underlying: Error)

    var isRetryable: Bool {
        switch self {
        case .network(let n):
            switch n {
            case .offline, .timeout, .connectionLost, .dns, .tls, .rateLimited:
                return true
            }
        case .server(let status, _):
            return (500...599).contains(status)
        case .decoding, .dataStore, .config, .cancelled, .unknown:
            return false
        }
    }

    static func from(_ error: Error, status: Int? = nil) -> AppError {
        if let app = error as? AppError { return app }
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain {
            switch ns.code {
            case NSURLErrorNotConnectedToInternet:
                return .network(.offline)
            case NSURLErrorTimedOut:
                return .network(.timeout)
            case NSURLErrorNetworkConnectionLost:
                return .network(.connectionLost)
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorDNSLookupFailed:
                return .network(.dns)
            case NSURLErrorSecureConnectionFailed:
                return .network(.tls)
            case NSURLErrorCancelled:
                return .cancelled
            default:
                break
            }
        }
        if let status = status {
            if status == 429 { return .network(.rateLimited(retryAfter: nil)) }
            return .server(status: status, message: nil)
        }
        if error is DecodingError { return .decoding(underlying: error) }
        return .unknown(underlying: error)
    }
}

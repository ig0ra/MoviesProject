//
//  ErrorPresenter.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation

enum ErrorPresenter {
    static func message(for error: Error) -> String {
        if let app = error as? AppError {
            switch app {
            case .network(let net):
                switch net {
                case .offline:
                    return L10n.Network.offlineMessage
                case .timeout:
                    return L10nError.networkTimeout
                case .connectionLost:
                    return L10nError.networkConnectionLost
                case .dns:
                    return L10nError.networkDNS
                case .tls:
                    return L10nError.networkTLS
                case .rateLimited:
                    return L10nError.networkRateLimited
                }
            case .server(let status, _):
                return String(format: L10nError.serverWithCode, status)
            case .decoding:
                return L10nError.decoding
            case .dataStore:
                return L10nError.dataStore
            case .config(let message):
                return message
            case .cancelled:
                return L10nError.cancelled
            case .unknown:
                return L10nError.unknown
            }
        }
        return error.localizedDescription
    }
}

enum L10nError {
    static var networkTimeout: String { NSLocalizedString("error_network_timeout", comment: "") }
    static var networkConnectionLost: String { NSLocalizedString("error_network_connection_lost", comment: "") }
    static var networkDNS: String { NSLocalizedString("error_network_dns", comment: "") }
    static var networkTLS: String { NSLocalizedString("error_network_tls", comment: "") }
    static var networkRateLimited: String { NSLocalizedString("error_network_rate_limited", comment: "") }
    static var serverWithCode: String { NSLocalizedString("error_server_with_code", comment: "") }
    static var decoding: String { NSLocalizedString("error_decoding", comment: "") }
    static var dataStore: String { NSLocalizedString("error_datastore", comment: "") }
    static var config: String { NSLocalizedString("error_config", comment: "") }
    static var cancelled: String { NSLocalizedString("error_cancelled", comment: "") }
    static var unknown: String { NSLocalizedString("error_unknown", comment: "") }
}

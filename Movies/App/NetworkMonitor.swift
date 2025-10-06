//
//  NetworkMonitor.swift
//  Movies
//
//  Created by Igor O on 10.09.2025.
//

import Foundation
import Network
import Combine

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    let isConnected = PassthroughSubject<Bool, Never>()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isSatisfied = path.status == .satisfied
            DispatchQueue.main.async {
                self?.isConnected.send(isSatisfied)
            }
        }
    }

    func start() {
        monitor.start(queue: .global())
    }

    func stop() {
        monitor.cancel()
    }
}

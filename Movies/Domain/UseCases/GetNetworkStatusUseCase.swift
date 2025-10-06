//
//  GetNetworkStatusUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Combine

protocol GetNetworkStatusUseCase {
    var networkStatusPublisher: AnyPublisher<Bool, Never> { get }
}

final class DefaultGetNetworkStatusUseCase: GetNetworkStatusUseCase {
    var networkStatusPublisher: AnyPublisher<Bool, Never> {
        NetworkMonitor.shared.isConnected.eraseToAnyPublisher()
    }
}

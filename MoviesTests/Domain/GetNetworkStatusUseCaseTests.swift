
//
//  GetNetworkStatusUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
import Combine
@testable import Movies

final class GetNetworkStatusUseCaseTests: XCTestCase {
    private var sut: DefaultGetNetworkStatusUseCase!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        sut = DefaultGetNetworkStatusUseCase()
    }

    override func tearDown() {
        cancellables.removeAll()
        sut = nil
        super.tearDown()
    }

    func test_networkStatusPublisher_forwardsValuesFromNetworkMonitor() {
        let exp = expectation(description: "receive two values")
        var received: [Bool] = []

        sut.networkStatusPublisher
            .sink { value in
                received.append(value)
                if received.count == 2 { exp.fulfill() }
            }
            .store(in: &cancellables)

        NetworkMonitor.shared.isConnected.send(true)
        NetworkMonitor.shared.isConnected.send(false)

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(received, [true, false])
    }
}



//
//  IsFavoriteUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class IsFavoriteUseCaseTests: XCTestCase {
    private var sut: DefaultIsFavoriteUseCase!
    private var store: MockFavoritesStore!

    override func setUp() {
        super.setUp()
        store = MockFavoritesStore()
        sut = DefaultIsFavoriteUseCase(store: store)
    }

    override func tearDown() {
        sut = nil
        store = nil
        super.tearDown()
    }

    func test_execute_whenIdIsFavorite_returnsTrue() async {
        store.seed([10])
        let value = await sut.execute(id: 10)
        XCTAssertTrue(value)
    }

    func test_execute_whenIdIsNotFavorite_returnsFalse() async {
        store.seed([10])
        let value = await sut.execute(id: 11)
        XCTAssertFalse(value)
    }
}


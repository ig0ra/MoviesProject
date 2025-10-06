
//
//  ToggleFavoriteUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class ToggleFavoriteUseCaseTests: XCTestCase {
    private var sut: DefaultToggleFavoriteUseCase!
    private var store: MockFavoritesStore!

    override func setUp() {
        super.setUp()
        store = MockFavoritesStore()
        sut = DefaultToggleFavoriteUseCase(store: store)
    }

    override func tearDown() {
        sut = nil
        store = nil
        super.tearDown()
    }

    func test_execute_whenNotFavorite_addsAndReturnsTrue() async {
        let result = await sut.execute(id: 5)
        let ids = await store.favoriteIds()
        XCTAssertTrue(result)
        XCTAssertTrue(ids.contains(5))
    }

    func test_execute_whenFavorite_removesAndReturnsFalse() async {
        store.seed([9])
        let result = await sut.execute(id: 9)
        let ids = await store.favoriteIds()
        XCTAssertFalse(result)
        XCTAssertFalse(ids.contains(9))
    }
}


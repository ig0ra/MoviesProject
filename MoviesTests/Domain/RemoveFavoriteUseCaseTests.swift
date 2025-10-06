
//
//  RemoveFavoriteUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class RemoveFavoriteUseCaseTests: XCTestCase {
    private var sut: DefaultRemoveFavoriteUseCase!
    private var store: MockFavoritesStore!

    override func setUp() {
        super.setUp()
        store = MockFavoritesStore()
        store.seed([77])
        sut = DefaultRemoveFavoriteUseCase(store: store)
    }

    override func tearDown() {
        sut = nil
        store = nil
        super.tearDown()
    }

    func test_execute_removesIdFromStore() async {
        await sut.execute(id: 77)
        let ids = await store.favoriteIds()
        XCTAssertFalse(ids.contains(77))
    }
}


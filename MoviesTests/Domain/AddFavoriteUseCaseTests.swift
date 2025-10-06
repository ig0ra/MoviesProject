//
//  AddFavoriteUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class AddFavoriteUseCaseTests: XCTestCase {
    private var sut: DefaultAddFavoriteUseCase!
    private var store: MockFavoritesStore!

    override func setUp() {
        super.setUp()
        store = MockFavoritesStore()
        sut = DefaultAddFavoriteUseCase(store: store)
    }

    override func tearDown() {
        sut = nil
        store = nil
        super.tearDown()
    }

    func test_execute_addsIdToStore() async {
        await sut.execute(id: 42)
        let ids = await store.favoriteIds()
        XCTAssertTrue(ids.contains(42))
    }
}

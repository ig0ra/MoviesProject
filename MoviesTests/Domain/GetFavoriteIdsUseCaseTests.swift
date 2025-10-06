//
//  GetFavoriteIdsUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class GetFavoriteIdsUseCaseTests: XCTestCase {
    private var sut: DefaultGetFavoriteIdsUseCase!
    private var store: MockFavoritesStore!

    override func setUp() {
        super.setUp()
        store = MockFavoritesStore()
        sut = DefaultGetFavoriteIdsUseCase(store: store)
    }

    override func tearDown() {
        sut = nil
        store = nil
        super.tearDown()
    }

    func test_execute_returnsIdsFromStore() async {
        // Given
        store.seed([1, 2, 3])

        // When
        let ids = await sut.execute()

        // Then
        XCTAssertEqual(ids, [1, 2, 3])
    }
}



//
//  GetGenresUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class GetGenresUseCaseTests: XCTestCase {

    private var sut: DefaultGetGenresUseCase!
    private var mockGenresStore: MockGenresStore!

    override func setUp() {
        super.setUp()
        mockGenresStore = MockGenresStore()
        sut = DefaultGetGenresUseCase(genresStore: mockGenresStore)
    }

    override func tearDown() {
        sut = nil
        mockGenresStore = nil
        super.tearDown()
    }

    func test_execute_whenStoreReturnsGenres_shouldReturnGenres() async {
        // Given
        let expectedGenres = [Genre(id: 1, name: "Action"), Genre(id: 2, name: "Comedy")]
        mockGenresStore.genresToReturn = expectedGenres
        
        // When
        let genres = await sut.execute()
        
        // Then
        XCTAssertEqual(genres.count, 2)
        XCTAssertEqual(genres, expectedGenres)
    }

    func test_execute_whenStoreReturnsEmpty_shouldReturnEmpty() async {
        // Given
        mockGenresStore.genresToReturn = []
        
        // When
        let genres = await sut.execute()
        
        // Then
        XCTAssertTrue(genres.isEmpty)
    }
}


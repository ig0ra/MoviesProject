
//
//  FilterMoviesUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 11.09.2025.
//

import XCTest
@testable import Movies

final class FilterMoviesUseCaseTests: XCTestCase {

    private var sut: DefaultFilterMoviesUseCase!

    override func setUp() {
        super.setUp()
        sut = DefaultFilterMoviesUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_execute_givenMatchingQuery_shouldReturnFilteredMovies() {
        // Given
        let movies = createMockMovies()
        let query = "Movie A"
        
        // When
        let filteredMovies = sut.execute(movies: movies, query: query)
        
        // Then
        XCTAssertEqual(filteredMovies.count, 1)
        XCTAssertEqual(filteredMovies.first?.id, 1)
    }

    func test_execute_givenMismatchedQuery_shouldReturnEmptyArray() {
        // Given
        let movies = createMockMovies()
        let query = "NonExistent"
        
        // When
        let filteredMovies = sut.execute(movies: movies, query: query)
        
        // Then
        XCTAssertTrue(filteredMovies.isEmpty)
    }

    func test_execute_givenEmptyQuery_shouldReturnAllMovies() {
        // Given
        let movies = createMockMovies()
        let query = ""
        
        // When
        let filteredMovies = sut.execute(movies: movies, query: query)
        
        // Then
        XCTAssertEqual(filteredMovies.count, 3)
    }
    
    func test_execute_givenWhitespaceQuery_shouldReturnAllMovies() {
        // Given
        let movies = createMockMovies()
        let query = "   "
        
        // When
        let filteredMovies = sut.execute(movies: movies, query: query)
        
        // Then
        XCTAssertEqual(filteredMovies.count, 3)
    }

    func test_execute_givenCaseInsensitiveQuery_shouldReturnFilteredMovies() {
        // Given
        let movies = createMockMovies()
        let query = "movie a"
        
        // When
        let filteredMovies = sut.execute(movies: movies, query: query)
        
        // Then
        XCTAssertEqual(filteredMovies.count, 1)
        XCTAssertEqual(filteredMovies.first?.id, 1)
    }

    // MARK: - Helpers

    private func createMockMovies() -> [Movie] {
        return [
            Movie(id: 1, title: "Movie A", posterPath: nil, overview: "", releaseDate: nil, genreIds: [], voteAverage: 0),
            Movie(id: 2, title: "Movie B", posterPath: nil, overview: "", releaseDate: nil, genreIds: [], voteAverage: 0),
            Movie(id: 3, title: "Another Movie C", posterPath: nil, overview: "", releaseDate: nil, genreIds: [], voteAverage: 0)
        ]
    }
}


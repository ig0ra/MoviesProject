
//
//  SearchMoviesUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 11.09.2025.
//

import XCTest
@testable import Movies

final class SearchMoviesUseCaseTests: XCTestCase {

    private var sut: DefaultSearchMoviesUseCase!
    private var mockMovieRepository: MockMovieRepository!

    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        sut = DefaultSearchMoviesUseCase(movieRepository: mockMovieRepository)
    }

    override func tearDown() {
        sut = nil
        mockMovieRepository = nil
        super.tearDown()
    }

    @MainActor
    func test_execute_whenRepositoryReturnsSuccess_shouldReturnPagedResponse() async throws {
        // Given
        let query = "Inception"
        let expectedResponse = PagedResponse<Movie>(page: 1, results: [createMockMovie(title: query)], totalPages: 1, totalResults: 1)
        mockMovieRepository.searchMoviesResult = .success(expectedResponse)
        
        // When
        let response = try await sut.execute(query: query, page: 1)

        // Then
        XCTAssertEqual(response.page, expectedResponse.page)
        XCTAssertEqual(response.results.count, expectedResponse.results.count)
        XCTAssertEqual(response.results.first?.title, query)
    }

    func test_execute_whenRepositoryReturnsFailure_shouldReturnError() async {
        // Given
        let query = "Inception"
        let expectedError = TestError.genericError
        mockMovieRepository.searchMoviesResult = .failure(expectedError)
        
        // When
        do {
            _ = try await sut.execute(query: query, page: 1)
            XCTFail("Expected failure but got success")
        } catch {
            XCTAssertEqual(error as? TestError, expectedError)
        }
    }
    
    // MARK: - Helpers
    
    private func createMockMovie(title: String) -> Movie {
        return Movie(id: 1, title: title, posterPath: nil, overview: "", releaseDate: nil, genreIds: [], voteAverage: 0)
    }
}


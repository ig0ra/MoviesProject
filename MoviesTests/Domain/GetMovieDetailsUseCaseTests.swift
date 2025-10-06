
//
//  GetMovieDetailsUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class GetMovieDetailsUseCaseTests: XCTestCase {

    private var sut: DefaultGetMovieDetailsUseCase!
    private var mockMovieRepository: MockMovieRepository!

    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        sut = DefaultGetMovieDetailsUseCase(repository: mockMovieRepository)
    }

    override func tearDown() {
        sut = nil
        mockMovieRepository = nil
        super.tearDown()
    }

    @MainActor
    func test_execute_whenRepositoryReturnsSuccess_shouldReturnMovieDetails() async throws {
        // Given
        let expectedDetails = createMockMovieDetails()
        mockMovieRepository.movieDetailsResult = .success(expectedDetails)
        
        // When
        let details = try await sut.execute(id: 1)

        // Then
        XCTAssertEqual(details.id, expectedDetails.id)
        XCTAssertEqual(details.title, expectedDetails.title)
    }

    func test_execute_whenRepositoryReturnsFailure_shouldReturnError() async {
        // Given
        let expectedError = TestError.genericError
        mockMovieRepository.movieDetailsResult = .failure(expectedError)
        
        // When
        do {
            _ = try await sut.execute(id: 1)
            XCTFail("Expected failure but got success")
        } catch {
            XCTAssertEqual(error as? TestError, expectedError)
        }
    }
    
    // MARK: - Helpers
    
    private func createMockMovieDetails() -> MovieDetails {
        return MovieDetails(id: 1, title: "Movie Title", posterPath: nil, overview: nil, releaseDate: nil, genres: [], voteAverage: 0, productionCountries: nil)
    }
}


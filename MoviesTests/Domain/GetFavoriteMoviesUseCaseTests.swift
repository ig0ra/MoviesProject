//
//  GetFavoriteMoviesUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class GetFavoriteMoviesUseCaseTests: XCTestCase {
    private var sut: DefaultGetFavoriteMoviesUseCase!
    private var repo: MockFavoriteMoviesRepository!

    override func setUp() {
        super.setUp()
        repo = MockFavoriteMoviesRepository()
        sut = DefaultGetFavoriteMoviesUseCase(repository: repo)
    }

    override func tearDown() {
        sut = nil
        repo = nil
        super.tearDown()
    }

    @MainActor
    func test_execute_whenRepositoryReturnsMovies_shouldReturnThem() async throws {
        // Given
        let movies = [Movie(id: 1, title: "A", posterPath: nil, overview: "", releaseDate: nil, genreIds: [], voteAverage: 0)]
        repo.result = .success(movies)

        // When
        let out = try await sut.execute()

        // Then
        XCTAssertEqual(out.count, 1)
        XCTAssertEqual(out.first?.id, 1)
    }

    @MainActor
    func test_execute_whenRepositoryFails_shouldThrow() async {
        // Given
        repo.result = .failure(TestError.genericError)

        // When
        do {
            _ = try await sut.execute()
            XCTFail("Expected failure")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }
}


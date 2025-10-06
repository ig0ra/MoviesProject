
//
//  GetMovieVideosUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class GetMovieVideosUseCaseTests: XCTestCase {

    private var sut: DefaultGetMovieVideosUseCase!
    private var mockMovieRepository: MockMovieRepository!

    override func setUp() {
        super.setUp()
        mockMovieRepository = MockMovieRepository()
        sut = DefaultGetMovieVideosUseCase(repository: mockMovieRepository)
    }

    override func tearDown() {
        sut = nil
        mockMovieRepository = nil
        super.tearDown()
    }

    @MainActor
    func test_execute_whenRepositoryReturnsSuccess_shouldReturnVideos() async throws {
        // Given
        let expectedVideos = [Video(id: "1", key: "key", name: "Trailer", site: "YouTube", type: "Trailer")]
        mockMovieRepository.movieVideosResult = .success(expectedVideos)
        
        // When
        let videos = try await sut.execute(id: 1)

        // Then
        XCTAssertEqual(videos.count, 1)
        XCTAssertEqual(videos.first?.id, expectedVideos.first?.id)
    }

    func test_execute_whenRepositoryReturnsFailure_shouldReturnError() async {
        // Given
        let expectedError = TestError.genericError
        mockMovieRepository.movieVideosResult = .failure(expectedError)
        
        // When
        do {
            _ = try await sut.execute(id: 1)
            XCTFail("Expected failure but got success")
        } catch {
            XCTAssertEqual(error as? TestError, expectedError)
        }
    }
}


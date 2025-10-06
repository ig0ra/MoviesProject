
//
//  GetImageURLUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class GetImageURLUseCaseTests: XCTestCase {

    private var sut: DefaultGetImageURLUseCase!
    private let baseURL = "https://image.tmdb.org/t/p/"

    override func setUp() {
        super.setUp()
        sut = DefaultGetImageURLUseCase(baseURL: baseURL)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_execute_givenW500Size_shouldConstructCorrectURL() {
        // Given
        let posterPath = "/poster.jpg"
        let expectedURLString = "https://image.tmdb.org/t/p/w500/poster.jpg"
        
        // When
        let url = sut.execute(with: posterPath, size: .w500)
        
        // Then
        XCTAssertEqual(url.absoluteString, expectedURLString)
    }

    func test_execute_givenOriginalSize_shouldConstructCorrectURL() {
        // Given
        let posterPath = "/poster.jpg"
        let expectedURLString = "https://image.tmdb.org/t/p/original/poster.jpg"
        
        // When
        let url = sut.execute(with: posterPath, size: .original)
        
        // Then
        XCTAssertEqual(url.absoluteString, expectedURLString)
    }
    
    func test_execute_whenDefaultingSize_shouldUseW500() {
        // Given
        let posterPath = "/poster.jpg"
        let expectedURLString = "https://image.tmdb.org/t/p/w500/poster.jpg"
        
        // When
        let url = sut.execute(with: posterPath)
        
        // Then
        XCTAssertEqual(url.absoluteString, expectedURLString)
    }
}


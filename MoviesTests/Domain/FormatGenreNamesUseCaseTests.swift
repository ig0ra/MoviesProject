//
//  FormatGenreNamesUseCaseTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class FormatGenreNamesUseCaseTests: XCTestCase {

    private var sut: DefaultFormatGenreNamesUseCase!

    override func setUp() {
        super.setUp()
        sut = DefaultFormatGenreNamesUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_execute_givenGenreIdsAndMap_shouldReturnCorrectNames() {
        // Given
        let genreIds = [28, 12, 878]
        let genreMap = [28: "Action", 12: "Adventure", 878: "Science Fiction"]
        
        // When
        let genreNames = sut.execute(genreIds: genreIds, genreMap: genreMap)
        
        // Then
        XCTAssertEqual(genreNames, ["Action", "Adventure", "Science Fiction"])
    }

    func test_execute_givenSomeInvalidIds_shouldReturnOnlyValidNames() {
        // Given
        let genreIds = [28, 99, 878] // 99 is an invalid ID
        let genreMap = [28: "Action", 12: "Adventure", 878: "Science Fiction"]
        
        // When
        let genreNames = sut.execute(genreIds: genreIds, genreMap: genreMap)
        
        // Then
        XCTAssertEqual(genreNames, ["Action", "Science Fiction"])
    }

    func test_execute_givenEmptyIds_shouldReturnEmptyArray() {
        // Given
        let genreIds: [Int] = []
        let genreMap = [28: "Action", 12: "Adventure", 878: "Science Fiction"]
        
        // When
        let genreNames = sut.execute(genreIds: genreIds, genreMap: genreMap)
        
        // Then
        XCTAssertTrue(genreNames.isEmpty)
    }
    
    func test_execute_givenEmptyMap_shouldReturnEmptyArray() {
        // Given
        let genreIds = [28, 12, 878]
        let genreMap: [Int: String] = [:]
        
        // When
        let genreNames = sut.execute(genreIds: genreIds, genreMap: genreMap)
        
        // Then
        XCTAssertTrue(genreNames.isEmpty)
    }
}


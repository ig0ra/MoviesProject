//
//  MapperTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class MapperTests: XCTestCase {

    @MainActor
    func test_movieMapper_mapsDTOtoDomain() throws {
        // Given
        let dto: PagedResponseDTO<MovieDTO> = try load(fromJSONFile: "MoviesPageResponse", in: .init(for: Self.self))
        
        // When
        let domainObject = MovieMapper.toDomain(dto: dto)
        
        // Then
        XCTAssertEqual(domainObject.page, 1)
        XCTAssertEqual(domainObject.results.count, 20)
        
        let firstMovie = domainObject.results.first
        XCTAssertEqual(firstMovie?.id, 755898)
        XCTAssertEqual(firstMovie?.title, "War of the Worlds")
        XCTAssertNotNil(firstMovie?.overview)
    }
}


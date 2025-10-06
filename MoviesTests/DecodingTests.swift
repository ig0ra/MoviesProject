//
//  DecodingTests.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest
@testable import Movies

final class DecodingTests: XCTestCase {

    @MainActor
    func test_popularMoviesResponse_decodesCorrectly() throws {
        // When
        let response: PagedResponseDTO<MovieDTO> = try load(fromJSONFile: "MoviesPageResponse", in: .init(for: Self.self))
        
        // Then
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.results.count, 20)
        
        let firstMovie = response.results.first
        XCTAssertEqual(firstMovie?.id, 755898)
        XCTAssertEqual(firstMovie?.title, "War of the Worlds")
    }
}


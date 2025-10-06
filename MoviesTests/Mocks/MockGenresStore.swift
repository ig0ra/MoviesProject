
//
//  MockGenresStore.swift
//  MoviesTests
//
//  Created by Igor O on 11.09.2025.
//

import Foundation
@testable import Movies

final class MockGenresStore: GenresStore {
    var genresToReturn: [Genre] = []
    var syncGenresCallCount = 0
    
    func genres() async -> [Genre] {
        return genresToReturn
    }
    
    func syncGenres() async {
        syncGenresCallCount += 1
    }
}


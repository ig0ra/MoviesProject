//
//  MockFavoriteMoviesRepository.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import Foundation
@testable import Movies

final class MockFavoriteMoviesRepository: FavoriteMoviesRepository {
    var result: Result<[Movie], Error>?

    func favoriteMovies() async throws -> [Movie] {
        guard let r = result else { throw TestError.mockNotConfigured }
        return try r.get()
    }
}

//
//  GetFavoriteMoviesUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol GetFavoriteMoviesUseCase {
    func execute() async throws -> [Movie]
}

final class DefaultGetFavoriteMoviesUseCase: GetFavoriteMoviesUseCase {
    private let repository: FavoriteMoviesRepository

    init(repository: FavoriteMoviesRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Movie] {
        try await repository.favoriteMovies()
    }
}

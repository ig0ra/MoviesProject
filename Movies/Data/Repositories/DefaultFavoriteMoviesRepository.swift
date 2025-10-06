//
//  DefaultFavoriteMoviesRepository.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

final class DefaultFavoriteMoviesRepository: FavoriteMoviesRepository {
    private let favoritesStore: FavoritesStore
    private let localDataSource: MovieLocalDataSource

    init(favoritesStore: FavoritesStore, localDataSource: MovieLocalDataSource) {
        self.favoritesStore = favoritesStore
        self.localDataSource = localDataSource
    }

    func favoriteMovies() async throws -> [Movie] {
        let ids = await favoritesStore.favoriteIds()
        return try await localDataSource.fetchMovies(ids: Array(ids))
    }
}

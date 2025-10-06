//
//  FavoriteMoviesRepository.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol FavoriteMoviesRepository {
    func favoriteMovies() async throws -> [Movie]
}

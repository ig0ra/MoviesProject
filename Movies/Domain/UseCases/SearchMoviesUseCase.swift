//
//  SearchMoviesUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol SearchMoviesUseCase {
    func execute(query: String, page: Int) async throws -> PagedResponse<Movie>
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {
    private let movieRepository: MovieRepository

    init(movieRepository: MovieRepository) {
        self.movieRepository = movieRepository
    }

    func execute(query: String, page: Int) async throws -> PagedResponse<Movie> {
        try await movieRepository.searchMovies(query: query, page: page)
    }
}

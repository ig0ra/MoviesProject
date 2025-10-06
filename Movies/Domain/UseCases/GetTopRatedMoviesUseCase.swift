//
//  GetTopRatedMoviesUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol GetTopRatedMoviesUseCase {
    func execute(page: Int) async throws -> PagedResponse<Movie>
}

final class DefaultGetTopRatedMoviesUseCase: GetTopRatedMoviesUseCase {
    private let movieRepository: MovieRepository

    init(movieRepository: MovieRepository) {
        self.movieRepository = movieRepository
    }

    func execute(page: Int) async throws -> PagedResponse<Movie> {
        try await movieRepository.getTopRatedMovies(page: page)
    }
}

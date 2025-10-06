
//
//  MockMovieRepository.swift
//  MoviesTests
//
//  Created by Igor O on 11.09.2025.
//

import Foundation
@testable import Movies

final class MockMovieRepository: MovieRepository {
    var topRatedMoviesResult: Result<PagedResponse<Movie>, Error>?
    var searchMoviesResult: Result<PagedResponse<Movie>, Error>?
    var movieDetailsResult: Result<MovieDetails, Error>?
    var movieVideosResult: Result<[Video], Error>?

    // MARK: - Protocol conformance (current)
    func getTopRatedMovies(page: Int) async throws -> PagedResponse<Movie> {
        guard let res = topRatedMoviesResult else { throw TestError.mockNotConfigured }
        return try res.get()
    }

    func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie> {
        guard let res = searchMoviesResult else { throw TestError.mockNotConfigured }
        return try res.get()
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        guard let res = movieDetailsResult else { throw TestError.mockNotConfigured }
        return try res.get()
    }

    func fetchMovieVideos(id: Int) async throws -> [Video] {
        guard let res = movieVideosResult else { throw TestError.mockNotConfigured }
        return try res.get()
    }
}

enum TestError: Error {
    case mockNotConfigured
    case genericError
}


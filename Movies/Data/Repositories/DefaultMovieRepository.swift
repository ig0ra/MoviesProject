//
//  DefaultMovieRepository.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

final class DefaultMovieRepository: MovieRepository {
    private let client: TMDBClient
    private let localDataSource: MovieLocalDataSource

    init(client: TMDBClient, localDataSource: MovieLocalDataSource) {
        self.client = client
        self.localDataSource = localDataSource
    }

    func getTopRatedMovies(page: Int) async throws -> PagedResponse<Movie> {
        do {
            let dto = try await RetryPolicy.execute(
                times: 2,
                shouldRetry: { err in (AppError.from(err)).isRetryable }
            ) { [client = self.client] in
                try await client.topRatedMovies(page: page)
            }
            let response = MovieMapper.toDomain(dto: dto)
            await localDataSource.save(movies: response.results)
            return response
        } catch {
            let appErr = AppError.from(error)
            guard page == 1 else { throw appErr }
            let movies = try await localDataSource.fetchMovies()
            return PagedResponse(page: 1, results: movies, totalPages: 1, totalResults: movies.count)
        }
    }

    func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie> {
        do {
            let dto = try await RetryPolicy.execute(
                times: 2,
                shouldRetry: { err in (AppError.from(err)).isRetryable }
            ) { [client = self.client] in
                try await client.searchMovies(query: query, page: page)
            }
            return MovieMapper.toDomain(dto: dto)
        } catch {
            let appErr = AppError.from(error)
            guard page == 1 else { throw appErr }
            let movies = try await localDataSource.fetchMovies()
            let filteredMovies = movies.filter { $0.title.localizedCaseInsensitiveContains(query) }
            return PagedResponse(page: 1, results: filteredMovies, totalPages: 1, totalResults: filteredMovies.count)
        }
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        let dto = try await client.fetchMovieDetails(id: id)
        return MovieDetailsMapper.toDomain(dto: dto)
    }

    func fetchMovieVideos(id: Int) async throws -> [Video] {
        let dto = try await client.fetchMovieVideos(id: id)
        return VideoMapper.toDomain(dto: dto)
    }
}

//
//  MovieRepository.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol MovieRepository {
    func getTopRatedMovies(page: Int) async throws -> PagedResponse<Movie>
    func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie>
    func fetchMovieDetails(id: Int) async throws -> MovieDetails
    func fetchMovieVideos(id: Int) async throws -> [Video]
}

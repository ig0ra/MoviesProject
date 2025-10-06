//
//  TMDBClient.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol TMDBClient {
    func topRatedMovies(page: Int) async throws -> PagedResponseDTO<MovieDTO>
    func searchMovies(query: String, page: Int) async throws -> PagedResponseDTO<MovieDTO>
    func fetchMovieDetails(id: Int) async throws -> MovieDetailsDTO
    func fetchMovieVideos(id: Int) async throws -> VideosResponseDTO
    func fetchGenres() async throws -> GenresResponseDTO
}

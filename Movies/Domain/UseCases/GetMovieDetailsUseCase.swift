//
//  GetMovieDetailsUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol GetMovieDetailsUseCase {
    func execute(id: Int) async throws -> MovieDetails
}

final class DefaultGetMovieDetailsUseCase: GetMovieDetailsUseCase {
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> MovieDetails {
        try await repository.fetchMovieDetails(id: id)
    }
}

//
//  GetMovieVideosUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol GetMovieVideosUseCase {
    func execute(id: Int) async throws -> [Video]
}

final class DefaultGetMovieVideosUseCase: GetMovieVideosUseCase {
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> [Video] {
        try await repository.fetchMovieVideos(id: id)
    }
}

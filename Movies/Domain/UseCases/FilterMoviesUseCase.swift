//
//  FilterMoviesUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol FilterMoviesUseCase {
    func execute(movies: [Movie], query: String) -> [Movie]
}

final class DefaultFilterMoviesUseCase: FilterMoviesUseCase {
    func execute(movies: [Movie], query: String) -> [Movie] {
        guard !query.isEmpty else { return movies }
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return movies }
        
        return movies.filter { movie in
            movie.title.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }
}

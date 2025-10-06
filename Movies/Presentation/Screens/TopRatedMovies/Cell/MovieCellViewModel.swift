//
//  MovieCellViewModel.swift
//  Movies
//
//  Created by Igor O on 11.09.2025.
//

//
//  MovieCellViewModel.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation

struct MovieCellViewModel {
    let id: Int
    let title: String
    let year: String
    let genres: String
    let rating: String
    let posterURL: URL?
    let isFavorite: Bool
    
    init(movie: Movie, genreNames: [String], isFavorite: Bool, getImageURLUseCase: GetImageURLUseCase) {
        self.id = movie.id
        self.title = movie.title
        self.year = Self.extractYear(from: movie.releaseDate)
        self.genres = genreNames.joined(separator: ", ")
        self.rating = String(format: "%.1f", movie.voteAverage)
        self.posterURL = movie.posterPath.flatMap { getImageURLUseCase.execute(with: $0, size: .w500) }
        self.isFavorite = isFavorite
    }
}

// MARK: - Private Helpers
private extension MovieCellViewModel {
    static func extractYear(from dateString: String?) -> String {
        dateString?.components(separatedBy: "-").first ?? ""
    }
}

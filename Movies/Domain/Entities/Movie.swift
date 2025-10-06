//
//  Movie.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

struct Movie: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: String?
    let genreIds: [Int]
    let voteAverage: Double
}

//
//  MovieDTO.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

struct MovieDTO: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: String?
    let genreIds: [Int]
    let voteAverage: Double

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case overview
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
    }
}

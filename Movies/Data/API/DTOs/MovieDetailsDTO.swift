//
//  MovieDetailsDTO.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

struct MovieDetailsDTO: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let overview: String?
    let releaseDate: String?
    let genres: [GenreDTO]
    let voteAverage: Double
    let productionCountries: [ProductionCountryDTO]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case overview
        case releaseDate = "release_date"
        case genres
        case voteAverage = "vote_average"
        case productionCountries = "production_countries"
    }
}

struct ProductionCountryDTO: Codable {
    let iso_3166_1: String
    let name: String
}

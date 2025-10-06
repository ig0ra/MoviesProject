//
//  MovieDetails.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

struct MovieDetails: Identifiable, Sendable {
    let id: Int
    let title: String
    let posterPath: String?
    let overview: String?
    let releaseDate: String?
    let genres: [Genre]
    let voteAverage: Double
    let productionCountries: [ProductionCountry]?

    var year: String? {
        guard let releaseDate = releaseDate, let date = Formatter.yyyyMMdd.date(from: releaseDate) else {
            return nil
        }
        return Formatter.yyyy.string(from: date)
    }

    var country: String? {
        productionCountries?.first?.iso_3166_1
    }
}

struct ProductionCountry: Sendable {
    let iso_3166_1: String
    let name: String
}

private extension Formatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let yyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}

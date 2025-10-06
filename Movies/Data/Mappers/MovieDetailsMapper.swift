//
//  MovieDetailsMapper.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

struct MovieDetailsMapper {
    static func toDomain(dto: MovieDetailsDTO) -> MovieDetails {
        let genres = dto.genres.map { GenreMapper.toDomain(dto: $0) }
        let countries = dto.productionCountries?.map { MovieDetailsMapper.toDomain(dto: $0) }
        return .init(id: dto.id,
                     title: dto.title,
                     posterPath: dto.posterPath,
                     overview: dto.overview,
                     releaseDate: dto.releaseDate,
                     genres: genres,
                     voteAverage: dto.voteAverage,
                     productionCountries: countries)
    }
    
    static func toDomain(dto: ProductionCountryDTO) -> ProductionCountry {
        return .init(iso_3166_1: dto.iso_3166_1, name: dto.name)
    }
}

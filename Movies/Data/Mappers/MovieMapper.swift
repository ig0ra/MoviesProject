//
//  MovieMapper.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

enum MovieMapper {
    static func toDomain(dto: MovieDTO) -> Movie {
        return .init(id: dto.id,
                     title: dto.title,
                     posterPath: dto.posterPath,
                     overview: dto.overview,
                     releaseDate: dto.releaseDate,
                     genreIds: dto.genreIds,
                     voteAverage: dto.voteAverage)
    }
    
    static func toDomain(dto: PagedResponseDTO<MovieDTO>) -> PagedResponse<Movie> {
        let mapped = dto.results.map { MovieMapper.toDomain(dto: $0) }
        return .init(page: dto.page,
                     results: mapped,
                     totalPages: dto.totalPages,
                     totalResults: dto.totalResults)
    }
}

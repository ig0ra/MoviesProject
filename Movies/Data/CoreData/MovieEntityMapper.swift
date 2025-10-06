
//
//  MovieEntityMapper.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation
import CoreData

struct MovieEntityMapper {
    static func toDomain(entity: MovieEntity) -> Movie {

        let genreIdsArray = entity.genreIds as? NSArray
        let genreIds = genreIdsArray?.compactMap { ($0 as? NSNumber)?.intValue } ?? []

        return .init(id: Int(entity.id),
                     title: entity.title ?? "",
                     posterPath: entity.posterPath,
                     overview: entity.overviewText ?? "",
                     releaseDate: entity.releaseDate,
                     genreIds: genreIds,
                     voteAverage: entity.voteAverage)
    }

    static func toEntity(domain: Movie, in context: NSManagedObjectContext) -> MovieEntity {
        let entity = MovieEntity(context: context)
        entity.id = Int64(domain.id)
        entity.title = domain.title
        entity.posterPath = domain.posterPath
        entity.overviewText = domain.overview
        entity.releaseDate = domain.releaseDate
        entity.genreIds = domain.genreIds as NSArray
        entity.voteAverage = domain.voteAverage
        entity.fetchedAt = Date()
        return entity
    }
}

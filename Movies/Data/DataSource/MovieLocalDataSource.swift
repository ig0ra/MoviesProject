//
//  MovieLocalDataSource.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation
import CoreData

protocol MovieLocalDataSource {
    func fetchMovies() async throws -> [Movie]
    func fetchMovies(ids: [Int]) async throws -> [Movie]
    func save(movies: [Movie]) async
}

final class DefaultMovieLocalDataSource: MovieLocalDataSource {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    func fetchMovies() async throws -> [Movie] {
        let context = coreDataStack.persistentContainer.newBackgroundContext()
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fetchedAt", ascending: false)]
                    let entities = try context.fetch(fetchRequest)
                    let movies = entities.map { MovieEntityMapper.toDomain(entity: $0) }
                    continuation.resume(returning: movies)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchMovies(ids: [Int]) async throws -> [Movie] {
        if ids.isEmpty { return [] }
        let context = coreDataStack.persistentContainer.newBackgroundContext()
        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id IN %@", ids.map { NSNumber(value: Int64($0)) })
                    let entities = try context.fetch(request)
                    let movies = entities.map { MovieEntityMapper.toDomain(entity: $0) }
                    let order: [Int: Int] = Dictionary(uniqueKeysWithValues: ids.enumerated().map { ($0.element, $0.offset) })
                    let sorted = movies.sorted { (a, b) -> Bool in
                        (order[a.id] ?? Int.max) < (order[b.id] ?? Int.max)
                    }
                    continuation.resume(returning: sorted)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func save(movies: [Movie]) async {
        let context = coreDataStack.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        context.perform { 
            do {
                let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                let existingEntities = try context.fetch(fetchRequest)
                var byId: [Int64: MovieEntity] = [:]
                byId.reserveCapacity(existingEntities.count)
                for e in existingEntities { byId[e.id] = e }

                for movie in movies {
                    if let entity = byId[Int64(movie.id)] {
                        entity.title = movie.title
                        entity.posterPath = movie.posterPath
                        entity.overviewText = movie.overview
                        entity.releaseDate = movie.releaseDate
                        entity.genreIds = movie.genreIds as NSArray
                        entity.voteAverage = movie.voteAverage
                        entity.fetchedAt = Date()
                    } else {
                        _ = MovieEntityMapper.toEntity(domain: movie, in: context)
                    }
                }
                
                try context.save()
            } catch {
                // mark: ignore save error
            }
        }
    }
}

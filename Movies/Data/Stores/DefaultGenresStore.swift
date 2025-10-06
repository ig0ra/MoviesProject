//
//  DefaultGenresStore.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

final class DefaultGenresStore: GenresStore {
    private let client: TMDBClient
    private var genresCache: [Genre] = []

    init(client: TMDBClient) {
        self.client = client
    }

    func genres() async -> [Genre] {
        if genresCache.isEmpty {
            await syncGenres()
        }
        return genresCache
    }

    func syncGenres() async {
        do {
            let response = try await client.fetchGenres()
            self.genresCache = response.genres.map(GenreMapper.toDomain)
        } catch {
            // mark: ignore sync error
        }
    }
}

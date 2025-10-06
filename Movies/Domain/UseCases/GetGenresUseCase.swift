
//
//  GetGenresUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol GetGenresUseCase {
    func execute() async -> [Genre]
}

final class DefaultGetGenresUseCase: GetGenresUseCase {
    private let genresStore: GenresStore

    init(genresStore: GenresStore) {
        self.genresStore = genresStore
    }

    func execute() async -> [Genre] {
        return await genresStore.genres()
    }
}

//
//  GetFavoriteIdsUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol GetFavoriteIdsUseCase {
    func execute() async -> Set<Int>
}

final class DefaultGetFavoriteIdsUseCase: GetFavoriteIdsUseCase {
    private let store: FavoritesStore

    init(store: FavoritesStore) {
        self.store = store
    }

    func execute() async -> Set<Int> {
        await store.favoriteIds()
    }
}

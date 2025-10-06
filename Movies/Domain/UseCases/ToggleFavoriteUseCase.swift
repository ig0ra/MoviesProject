//
//  ToggleFavoriteUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol ToggleFavoriteUseCase {
    func execute(id: Int) async -> Bool
}

final class DefaultToggleFavoriteUseCase: ToggleFavoriteUseCase {
    private let store: FavoritesStore

    init(store: FavoritesStore) {
        self.store = store
    }

    func execute(id: Int) async -> Bool {
        if await store.isFavorite(id: id) {
            await store.remove(id: id)
            return false
        } else {
            await store.add(id: id)
            return true
        }
    }
}

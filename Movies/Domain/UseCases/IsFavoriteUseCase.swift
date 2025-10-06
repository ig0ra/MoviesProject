//
//  IsFavoriteUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol IsFavoriteUseCase {
    func execute(id: Int) async -> Bool
}

final class DefaultIsFavoriteUseCase: IsFavoriteUseCase {
    private let store: FavoritesStore

    init(store: FavoritesStore) {
        self.store = store
    }

    func execute(id: Int) async -> Bool {
        await store.isFavorite(id: id)
    }
}

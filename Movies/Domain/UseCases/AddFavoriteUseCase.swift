//
//  AddFavoriteUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol AddFavoriteUseCase {
    func execute(id: Int) async
}

final class DefaultAddFavoriteUseCase: AddFavoriteUseCase {
    private let store: FavoritesStore

    init(store: FavoritesStore) {
        self.store = store
    }

    func execute(id: Int) async {
        await store.add(id: id)
    }
}

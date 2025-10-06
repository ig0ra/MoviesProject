//
//  FavoritesStore.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol FavoritesStore {
    func favoriteIds() async -> Set<Int>
    func isFavorite(id: Int) async -> Bool
    func add(id: Int) async
    func remove(id: Int) async
}

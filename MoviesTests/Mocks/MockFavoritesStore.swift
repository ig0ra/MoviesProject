//
//  MockFavoritesStore.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import Foundation
@testable import Movies

final class MockFavoritesStore: FavoritesStore {
    private(set) var ids: Set<Int> = []
    private(set) var addCalls: [Int] = []
    private(set) var removeCalls: [Int] = []

    func favoriteIds() async -> Set<Int> {
        ids
    }

    func isFavorite(id: Int) async -> Bool {
        ids.contains(id)
    }

    func add(id: Int) async {
        ids.insert(id)
        addCalls.append(id)
    }

    func remove(id: Int) async {
        ids.remove(id)
        removeCalls.append(id)
    }

    func seed(_ initial: Set<Int>) { ids = initial }
}

//
//  GenresStore.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol GenresStore {
    func genres() async -> [Genre]
    func syncGenres() async
}

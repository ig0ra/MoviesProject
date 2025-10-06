//
//  MoviesDisplayModel.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation

struct MoviesDisplayModel {
    let movies: [Movie]
    let totalPages: Int
    let currentPage: Int
    let isLastPage: Bool
    
    init(movies: [Movie] = [], totalPages: Int = 1, currentPage: Int = 1) {
        self.movies = movies
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.isLastPage = currentPage >= totalPages
    }
    
    static let empty = MoviesDisplayModel()
}

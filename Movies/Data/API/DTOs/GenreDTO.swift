//
//  GenreDTO.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

struct GenreDTO: Codable {
    let id: Int
    let name: String
}

struct GenresResponseDTO: Codable {
    let genres: [GenreDTO]
}

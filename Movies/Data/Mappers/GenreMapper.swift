//
//  GenreMapper.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

struct GenreMapper {
    static func toDomain(dto: GenreDTO) -> Genre {
        return .init(id: dto.id, name: dto.name)
    }
}

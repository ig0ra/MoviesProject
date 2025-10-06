//
//  FormatGenreNamesUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

protocol FormatGenreNamesUseCase {
    func execute(genreIds: [Int], genreMap: [Int: String]) -> [String]
}

final class DefaultFormatGenreNamesUseCase: FormatGenreNamesUseCase {
    func execute(genreIds: [Int], genreMap: [Int: String]) -> [String] {
        genreIds.compactMap { genreMap[$0] }
    }
}

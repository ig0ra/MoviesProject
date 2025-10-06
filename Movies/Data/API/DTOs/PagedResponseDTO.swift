//
//  PagedResponseDTO.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

struct PagedResponseDTO<T: Codable>: Codable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

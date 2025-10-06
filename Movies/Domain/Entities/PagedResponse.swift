//
//  PagedResponse.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

struct PagedResponse<T: Sendable>: Sendable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int
}

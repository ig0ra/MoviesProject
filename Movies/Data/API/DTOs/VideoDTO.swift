//
//  VideoDTO.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

struct VideoDTO: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case id
        case key
        case name
        case site
        case type
    }
}

struct VideosResponseDTO: Codable {
    let id: Int
    let results: [VideoDTO]
}

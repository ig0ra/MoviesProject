//
//  Video.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

struct Video: Identifiable, Hashable, Sendable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}

//
//  VideoMapper.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

struct VideoMapper {
    static func toDomain(dto: VideoDTO) -> Video {
        return .init(id: dto.id, key: dto.key, name: dto.name, site: dto.site, type: dto.type)
    }
    
    static func toDomain(dto: VideosResponseDTO) -> [Video] {
        return dto.results.map { VideoMapper.toDomain(dto: $0) }
    }
}

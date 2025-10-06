//
//  GetImageURLUseCase.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import Foundation

enum ImageSize: String {
    case original, w500
}

protocol GetImageURLUseCase {
    func execute(with path: String, size: ImageSize) -> URL
}

final class DefaultGetImageURLUseCase: GetImageURLUseCase {
    let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func execute(with posterPath: String, size: ImageSize = .w500) -> URL {
        URL(string: "\(baseURL)\(size.rawValue)\(posterPath)")!
    }
}

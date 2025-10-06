//
//  XCTestCase+JSON.swift
//  MoviesTests
//
//  Created by Igor O on 05.10.2025.
//

import XCTest

extension XCTestCase {
    func load<T: Decodable>(fromJSONFile file: String, in bundle: Bundle? = nil) throws -> T {
        let testBundle = bundle ?? Bundle(for: type(of: self))
        guard let url = testBundle.url(forResource: file, withExtension: "json") else {
            fatalError("Could not find \(file).json in test bundle.")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}


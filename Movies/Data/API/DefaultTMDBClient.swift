//
//  DefaultTMDBClient.swift
//  Movies
//
//  Created by Igor O on 03.10.2025.
//

import Foundation

final class DefaultTMDBClient: TMDBClient {

    private let session: URLSession
    private let baseURL: String
    private let apiKey: String

    init(session: URLSession = .shared, baseURL: String, apiKey: String) {
        self.session = session
        self.baseURL = baseURL
        self.apiKey = apiKey
    }

    func topRatedMovies(page: Int) async throws -> PagedResponseDTO<MovieDTO> {
        try await request(.topRated(page: page))
    }

    func searchMovies(query: String, page: Int) async throws -> PagedResponseDTO<MovieDTO> {
        try await request(.search(query: query, page: page))
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetailsDTO {
        try await request(.details(id: id))
    }

    func fetchMovieVideos(id: Int) async throws -> VideosResponseDTO {
        try await request(.videos(id: id))
    }

    func fetchGenres() async throws -> GenresResponseDTO {
        try await request(.genres)
    }

    private func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard var components = URLComponents(string: baseURL) else {
            throw AppError.config(message: "Invalid base URL")
        }
        components.path += endpoint.path

        var queryItems: [URLQueryItem] = []
        for (k, v) in endpoint.parameters.merging(["api_key": apiKey], uniquingKeysWith: { (_, new) in new }) {
            queryItems.append(URLQueryItem(name: k, value: String(describing: v)))
        }
        if !queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }

        guard let url = components.url else { throw AppError.config(message: "Invalid URL components") }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let (data, response) = try await data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AppError.network(.dns)
        }

        let status = http.statusCode
        guard (200...299).contains(status) else {
            if status == 429 {
                let header = http.value(forHTTPHeaderField: "Retry-After")
                let retryAfter = Self.parseRetryAfter(header)
                throw AppError.network(.rateLimited(retryAfter: retryAfter))
            }
            throw AppError.server(status: status, message: nil)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.decoding(underlying: error)
        }
    }

    private func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                throw AppError.cancelled
            }
            throw AppError.from(error)
        }
    }

    private static func parseRetryAfter(_ header: String?) -> TimeInterval? {
        guard let header = header else { return nil }
        if let seconds = TimeInterval(header) { return seconds }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss zzz"
        if let date = formatter.date(from: header) {
            return max(0, date.timeIntervalSinceNow)
        }
        return nil
    }
}

private extension DefaultTMDBClient {
    enum Endpoint {
        case topRated(page: Int)
        case search(query: String, page: Int)
        case details(id: Int)
        case videos(id: Int)
        case genres

        var path: String {
            switch self {
            case .topRated:
                return "/movie/top_rated"
            case .search:
                return "/search/movie"
            case .details(let id):
                return "/movie/\(id)"
            case .videos(let id):
                return "/movie/\(id)/videos"
            case .genres:
                return "/genre/movie/list"
            }
        }

        var parameters: [String: Any] {
            switch self {
            case .topRated(let page):
                return ["page": page]
            case .search(let query, let page):
                return ["query": query, "page": page]
            case .details, .videos, .genres:
                return [:]
            }
        }
    }
}

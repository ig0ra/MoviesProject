//
//  Paginator.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation

actor Paginator<Item> {
    enum State {
        case idle
        case loading
        case end
    }

    private(set) var state: State = .idle
    private(set) var items: [Item] = []

    private(set) var currentPage = 0
    private(set) var totalPages = 1
    private let loader: (Int) async throws -> PagedResponse<Item>
    private let pagesPerBatch: Int

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    init(pagesPerBatch: Int = 1, loader: @escaping (Int) async throws -> PagedResponse<Item>) {
        self.loader = loader
        self.pagesPerBatch = max(1, pagesPerBatch)
    }

    func loadNextPage() async throws {
        guard state == .idle && hasMorePages else { return }

        state = .loading

        let startPage = currentPage + 1
        let endPage = startPage + (pagesPerBatch - 1)
        try? Task.checkCancellation()

        if pagesPerBatch == 1 {
            do {
                let response = try await loader(startPage)
                items.append(contentsOf: response.results)
                currentPage = response.page
                totalPages = response.totalPages
                state = hasMorePages ? .idle : .end
            } catch {
                state = .idle
                throw error
            }
            return
        }

        var responses: [PagedResponse<Item>] = []
        var errors: [Error] = []

        let pagesToFetch: [Int] = {
            let range = Array(startPage...endPage)
            return (currentPage > 0) ? range.filter { $0 <= totalPages } : range
        }()

        await withTaskGroup(of: (Int, Result<PagedResponse<Item>, Error>).self) { group in
            for p in pagesToFetch where p >= startPage {
                group.addTask { [loader] in
                    do {
                        let r = try await loader(p)
                        return (p, .success(r))
                    } catch {
                        return (p, .failure(error))
                    }
                }
            }
            for await (_, result) in group {
                switch result {
                case .success(let r):
                    responses.append(r)
                case .failure(let e):
                    errors.append(e)
                }
            }
        }

        if responses.isEmpty {
            state = .idle
            if let err = errors.first { throw err }
            return
        }

        responses.sort { $0.page < $1.page }
        for r in responses {
            items.append(contentsOf: r.results)
        }

        if let last = responses.last {
            currentPage = last.page
            totalPages = last.totalPages
        }

        state = hasMorePages ? .idle : .end
    }

    func reset() {
        currentPage = 0
        totalPages = 1
        items = []
        state = .idle
    }
}

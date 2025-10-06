//
//  ViewState.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case refreshing
    case loadingMore
    case loaded(T)
    case empty(String)
    case error(Error)
    
    var isLoading: Bool {
        switch self {
        case .loading, .refreshing, .loadingMore:
            return true
        default:
            return false
        }
    }
    
    var shouldShowInitialLoader: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var shouldShowRefreshControl: Bool {
        if case .refreshing = self { return true }
        return false
    }
    
    var shouldShowPaginationLoader: Bool {
        if case .loadingMore = self { return true }
        return false
    }
    
    var currentMovies: T? {
        switch self {
        case .loaded(let movies):
            return movies
        case .loadingMore, .refreshing:
            return nil
        default:
            return nil
        }
    }
    
    var hasMorePages: Bool {
        if let model = currentMovies as? MoviesDisplayModel {
            return !model.isLastPage
        }
        return false
    }
}

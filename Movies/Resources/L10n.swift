//
//  L10n.swift
//  Movies
//
//  Created by Igor O on 21.09.2025.
//

import Foundation

enum L10n {
    private static func tr(_ key: String, _ comment: String = "") -> String {
        NSLocalizedString(key, comment: comment)
    }

    enum TopRated {
        static let title = tr("top_rated_movies_title")
        static let searchPlaceholder = tr("search_movies_placeholder")
        static let headerTitle = tr("top_rated_movies_header_title")
    }

    enum Empty {
        static let noMovies = tr("no_movies_found_empty_state")
        static let noMoviesSearch = tr("no_movies_found_search_empty_state")
    }

    enum Common {
        static let ok = tr("ok_button")
        static let cancel = tr("cancel_button")
        static let retry = tr("retry_button")
        static let errorTitle = tr("error_alert_title")
        static let errorPrefix = tr("error_prefix")
        static let ratingPrefix = tr("rating_prefix")
    }

    enum Network {
        static let offlineMessage = tr("offline_alert_message")
        static let offlineCached = tr("offline_cached_banner")
    }

    enum Refresh {
        static let refreshing = tr("refreshing")
        static let pullToRefresh = tr("pull_to_refresh")
    }

    enum Details {
        static let watchTrailer = tr("watch_trailer_button")
        static let addToFavorites = tr("add_to_favorites_button")
        static let removeFromFavorites = tr("remove_from_favorites_button")
    }

    enum Search {
        static let title = tr("search_title")
        static func resultsTitle(_ count: Int) -> String {
            String(format: tr("search_results_count"), count)
        }
    }

    enum Favorites {
        static let title = tr("favorites_title")
    }
}

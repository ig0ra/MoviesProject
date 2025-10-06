//
//  FavoritesViewModel.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation
import Combine

@MainActor
final class FavoritesViewModel {
    enum NavigationEvent {
        case showMovieDetails(Movie)
        case close
    }

    @Published private(set) var viewState: ViewState<MoviesDisplayModel> = .idle

    let navigationEvent = PassthroughSubject<NavigationEvent, Never>()

    private let getFavoriteMoviesUseCase: GetFavoriteMoviesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let formatGenreNamesUseCase: FormatGenreNamesUseCase
    private let getImageURLUseCase: GetImageURLUseCase

    init(
        getFavoriteMoviesUseCase: GetFavoriteMoviesUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        formatGenreNamesUseCase: FormatGenreNamesUseCase,
        getImageURLUseCase: GetImageURLUseCase
    ) {
        self.getFavoriteMoviesUseCase = getFavoriteMoviesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.formatGenreNamesUseCase = formatGenreNamesUseCase
        self.getImageURLUseCase = getImageURLUseCase
    }

    func load() {
        viewState = .loading
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let movies = try await self.getFavoriteMoviesUseCase.execute()
                let model = MoviesDisplayModel(movies: movies, totalPages: 1, currentPage: 1)
                viewState = movies.isEmpty ? .empty(L10n.Empty.noMovies) : .loaded(model)
            } catch {
                viewState = .error(error)
            }
        }
    }

    func refresh() { load() }

    func selectMovie(withId id: Int) {
        if let movies = viewState.currentMovies?.movies,
           let movie = movies.first(where: { $0.id == id }) {
            navigationEvent.send(.showMovieDetails(movie))
        }
    }

    func createCellViewModel(for movie: Movie) -> MovieCellViewModel {
        let names = formatGenreNamesUseCase.execute(genreIds: movie.genreIds, genreMap: [:])
        return MovieCellViewModel(movie: movie, genreNames: names, isFavorite: true, getImageURLUseCase: getImageURLUseCase)
    }

    func toggleFavorite(id: Int) {
        Task { [weak self] in
            guard let self = self else { return }
            let newValue = await self.toggleFavoriteUseCase.execute(id: id)
            if newValue == false {
                if case .loaded(let model) = self.viewState {
                    let filtered = model.movies.filter { $0.id != id }
                    if filtered.isEmpty {
                        self.viewState = .empty(L10n.Empty.noMovies)
                    } else {
                        self.viewState = .loaded(MoviesDisplayModel(movies: filtered, totalPages: 1, currentPage: 1))
                    }
                }
            }
        }
    }
}

//
//  SearchMoviesViewModel.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation
import Combine

@MainActor
final class SearchMoviesViewModel {
    // MARK: - Types
    enum NavigationEvent {
        case showMovieDetails(Movie)
    }

    // MARK: - Published
    @Published private(set) var viewState: ViewState<MoviesDisplayModel> = .idle
    @Published private(set) var isNetworkAvailable: Bool = true

    // MARK: - Streams
    let navigationEvent = PassthroughSubject<NavigationEvent, Never>()
    let searchQuery = PassthroughSubject<String, Never>()
    let loadMoreError = PassthroughSubject<Error, Never>()

    // MARK: - Deps
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let getGenresUseCase: GetGenresUseCase
    private let formatGenreNamesUseCase: FormatGenreNamesUseCase
    private let getNetworkStatusUseCase: GetNetworkStatusUseCase
    private let getFavoriteIdsUseCase: GetFavoriteIdsUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let getImageURLUseCase: GetImageURLUseCase

    // MARK: - State
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?
    private var currentQuery: String = ""
    private var genreMap: [Int: String] = [:]
    private var favoriteIds: Set<Int> = []

    private lazy var paginator: Paginator<Movie> = {
        Paginator(pagesPerBatch: 2, loader: { [weak self] page in
            guard let self = self, self.currentQuery.count >= 3 else {
                return PagedResponse(page: 0, results: [], totalPages: 0, totalResults: 0)
            }
            let response = try await self.searchMoviesUseCase.execute(query: self.currentQuery, page: page)
            return response
        })
    }()

    // MARK: - Init
    init(
        searchMoviesUseCase: SearchMoviesUseCase,
        getGenresUseCase: GetGenresUseCase,
        formatGenreNamesUseCase: FormatGenreNamesUseCase,
        getNetworkStatusUseCase: GetNetworkStatusUseCase,
        getFavoriteIdsUseCase: GetFavoriteIdsUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        getImageURLUseCase: GetImageURLUseCase
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.getGenresUseCase = getGenresUseCase
        self.formatGenreNamesUseCase = formatGenreNamesUseCase
        self.getNetworkStatusUseCase = getNetworkStatusUseCase
        self.getFavoriteIdsUseCase = getFavoriteIdsUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.getImageURLUseCase = getImageURLUseCase

        bind()
    }

    deinit { loadTask?.cancel() }

    // MARK: - Public
    func refresh() { loadForCurrentQuery(isRefresh: true) }

    func reloadFavorites() {
        Task { [weak self] in
            guard let self = self else { return }
            self.favoriteIds = await self.getFavoriteIdsUseCase.execute()
            self.updateViewState()
        }
    }

    func selectMovie(withId id: Int) {
        Task { [weak self] in
            guard let self = self else { return }
            let items = await self.paginator.items
            if let movie = items.first(where: { $0.id == id }) {
                self.navigationEvent.send(.showMovieDetails(movie))
            }
        }
    }

    func loadNextPageIfNeeded(currentIndex: Int) {
        guard let movies = viewState.currentMovies?.movies, currentIndex >= movies.count - 5 else { return }
        guard !viewState.isLoading else { return }
        Task { [weak self] in
            guard let self = self else { return }
            if await self.paginator.hasMorePages {
                self.loadNextPage()
            }
        }
    }

    func cancelPrefetchIfNeeded() {
        return
    }

    func createCellViewModel(for movie: Movie) -> MovieCellViewModel {
        let genreNames = formatGenreNamesUseCase.execute(genreIds: movie.genreIds, genreMap: genreMap)
        return MovieCellViewModel(movie: movie,
                                  genreNames: genreNames,
                                  isFavorite: favoriteIds.contains(movie.id),
                                  getImageURLUseCase: getImageURLUseCase)
    }

    // MARK: - Private
    private func bind() {
        getNetworkStatusUseCase.networkStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in self?.isNetworkAvailable = isConnected }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadFavorites()
            }
            .store(in: &cancellables)

        searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                self.currentQuery = trimmed
                if trimmed.count >= 3 {
                    self.loadForCurrentQuery(isRefresh: true)
                } else {
                    self.loadTask?.cancel()
                    Task { [weak self] in
                        guard let self = self else { return }
                        await self.paginator.reset()
                        self.viewState = .idle
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func loadForCurrentQuery(isRefresh: Bool) {
        loadTask?.cancel()
        updateLoadingState(isRefresh: isRefresh)
        loadTask = Task { [weak self] in
            guard let self = self else { return }
            if isRefresh { await self.paginator.reset() }
            await self.fetchMovies(isRefresh: isRefresh)
        }
    }

    private func loadNextPage() {
        guard case .loaded = viewState else { return }
        viewState = .loadingMore
        loadTask = Task { [weak self] in
            await self?.fetchMovies(isRefresh: false)
        }
    }

    private func fetchMovies(isRefresh: Bool) async {
        await ensureGenresLoaded()
        await ensureFavoritesLoaded()
        do {
            try await paginator.loadNextPage()
            if isRefresh { try? await Task.sleep(nanoseconds: 300_000_000) }
            updateViewState()
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        if (error is CancellationError) { return }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled { return }
        if case .loadingMore = viewState { loadMoreError.send(error) }
        if viewState.currentMovies?.movies.isEmpty == false {
            updateViewState()
        } else {
            viewState = .error(error)
        }
    }

    private func ensureGenresLoaded() async {
        guard genreMap.isEmpty else { return }
        let genres = await getGenresUseCase.execute()
        genreMap = Dictionary(uniqueKeysWithValues: genres.map { ($0.id, $0.name) })
    }

    private func ensureFavoritesLoaded() async {
        if favoriteIds.isEmpty {
            favoriteIds = await getFavoriteIdsUseCase.execute()
        }
    }

    func toggleFavorite(withId id: Int) {
        Task { [weak self] in
            guard let self = self else { return }
            let newValue = await self.toggleFavoriteUseCase.execute(id: id)
            if newValue { self.favoriteIds.insert(id) } else { self.favoriteIds.remove(id) }
            await MainActor.run { self.updateViewState() }
        }
    }

    private func updateLoadingState(isRefresh: Bool) {
        if isRefresh {
            if currentQuery.count >= 3 {
                viewState = .refreshing
            } else {
                viewState = .idle
            }
        } else if viewState.currentMovies == nil {
            viewState = .loading
        }
    }

    private func updateViewState() {
        Task { [weak self] in
            guard let self = self else { return }
            let movies = await self.paginator.items
            let total = await self.paginator.totalPages
            let page = await self.paginator.currentPage
            let model = MoviesDisplayModel(movies: movies, totalPages: total, currentPage: page)
            if model.movies.isEmpty {
                viewState = .empty(L10n.Empty.noMoviesSearch)
            } else {
                viewState = .loaded(model)
            }
        }
    }
}

//
//  TopRatedMoviesViewModel.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation
import Combine

@MainActor
final class TopRatedMoviesViewModel {
    // MARK: - Types
    enum NavigationEvent {
        case showMovieDetails(Movie)
    }
    
    // MARK: - Published Properties
    @Published private(set) var viewState: ViewState<MoviesDisplayModel> = .idle
    @Published private(set) var isNetworkAvailable: Bool = true
    
    let navigationEvent = PassthroughSubject<NavigationEvent, Never>()
    let loadMoreError = PassthroughSubject<Error, Never>()
    
    // MARK: - Properties
    private let getTopRatedMoviesUseCase: GetTopRatedMoviesUseCase
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let getGenresUseCase: GetGenresUseCase
    private let formatGenreNamesUseCase: FormatGenreNamesUseCase
    private let getNetworkStatusUseCase: GetNetworkStatusUseCase
    private let getFavoriteIdsUseCase: GetFavoriteIdsUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let getImageURLUseCase: GetImageURLUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?
    private var initialLoadStart: Date?
    private var didCompleteInitialLoad = false
    private var shouldSuppressEmptyState = false
    private var pendingEmptyTask: Task<Void, Never>?
    
    private var genreMap: [Int: String] = [:]
    private var favoriteIds: Set<Int> = []
    
    private lazy var topRatedPaginator: Paginator<Movie> = {
        Paginator(pagesPerBatch: 2, loader: { [weak self] page in
            guard let self = self else { throw CancellationError() }
            let response = try await self.getTopRatedMoviesUseCase.execute(page: page)
            return response
        })
    }()
    
    private var currentPaginator: Paginator<Movie> { topRatedPaginator }
    
    // MARK: - Initialization
    init(
        getTopRatedMoviesUseCase: GetTopRatedMoviesUseCase,
        searchMoviesUseCase: SearchMoviesUseCase,
        getGenresUseCase: GetGenresUseCase,
        formatGenreNamesUseCase: FormatGenreNamesUseCase,
        getNetworkStatusUseCase: GetNetworkStatusUseCase,
        getFavoriteIdsUseCase: GetFavoriteIdsUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        getImageURLUseCase: GetImageURLUseCase
    ) {
        self.getTopRatedMoviesUseCase = getTopRatedMoviesUseCase
        self.searchMoviesUseCase = searchMoviesUseCase
        self.getGenresUseCase = getGenresUseCase
        self.formatGenreNamesUseCase = formatGenreNamesUseCase
        self.getNetworkStatusUseCase = getNetworkStatusUseCase
        self.getFavoriteIdsUseCase = getFavoriteIdsUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.getImageURLUseCase = getImageURLUseCase
        
        getNetworkStatusUseCase.networkStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isNetworkAvailable = isConnected
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadFavorites()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        loadTask?.cancel()
    }
    
    // MARK: - Public Methods
    func loadInitialData() {
        loadMovies(isRefresh: false)
    }

    func reloadFavorites() {
        Task { [weak self] in
            guard let self = self else { return }
            self.favoriteIds = await self.getFavoriteIdsUseCase.execute()
            self.updateViewState()
        }
    }
    
    func refresh() {
        guard !viewState.isLoading else { return }
        loadMovies(isRefresh: true)
    }
    
    func loadNextPageIfNeeded(currentIndex: Int) {
        guard let movies = viewState.currentMovies?.movies, currentIndex >= movies.count - 5 else { return }
        guard !viewState.isLoading else { return }
        Task { [weak self] in
            guard let self = self else { return }
            if await self.currentPaginator.hasMorePages {
                self.loadNextPage()
            }
        }
    }

    func cancelPrefetchIfNeeded() {
        return
    }

    func retryLoadMore() {
        guard !viewState.isLoading else { return }
        Task { [weak self] in
            guard let self = self else { return }
            if await self.currentPaginator.hasMorePages {
                await MainActor.run { self.viewState = .loadingMore }
                self.loadTask = Task { [weak self] in
                    await self?.fetchMovies(isRefresh: false)
                }
            }
        }
    }
    
    func selectMovie(at index: Int) {
        guard let movies = viewState.currentMovies?.movies, movies.indices.contains(index) else { return }
        let movie = movies[index]
        navigationEvent.send(.showMovieDetails(movie))
    }

    func selectMovie(withId id: Int) {
        if let movies = viewState.currentMovies?.movies,
           let movie = movies.first(where: { $0.id == id }) {
            navigationEvent.send(.showMovieDetails(movie))
            return
        }

        Task { [weak self] in
            guard let self = self else { return }
            let items = await self.currentPaginator.items
            if let movie = items.first(where: { $0.id == id }) {
                self.navigationEvent.send(.showMovieDetails(movie))
            }
        }
    }
    
    func createCellViewModel(for movie: Movie) -> MovieCellViewModel {
        let genreNames = formatGenreNamesUseCase.execute(
            genreIds: movie.genreIds,
            genreMap: genreMap
        )
        return MovieCellViewModel(
            movie: movie,
            genreNames: genreNames,
            isFavorite: favoriteIds.contains(movie.id),
            getImageURLUseCase: getImageURLUseCase
        )
    }

    func toggleFavorite(withId id: Int) {
        Task { [weak self] in
            guard let self = self else { return }
            let newValue = await self.toggleFavoriteUseCase.execute(id: id)
            if newValue {
                self.favoriteIds.insert(id)
            } else {
                self.favoriteIds.remove(id)
            }
            await MainActor.run { self.updateViewState() }
        }
    }
}

// MARK: - Private Methods
private extension TopRatedMoviesViewModel {
    
    func loadMovies(isRefresh: Bool) {
        loadTask?.cancel()
        pendingEmptyTask?.cancel()
        
        updateLoadingState(isRefresh: isRefresh)
        
        loadTask = Task {
            if !isRefresh && viewState.currentMovies == nil {
                initialLoadStart = Date()
                shouldSuppressEmptyState = true
            }
            if isRefresh {
                await currentPaginator.reset()
            }
            await fetchMovies(isRefresh: isRefresh)
        }
    }
    
    func loadNextPage() {
        guard case .loaded = viewState else { return }
        viewState = .loadingMore
        
        loadTask = Task {
            await fetchMovies(isRefresh: false)
        }
    }
    
    func fetchMovies(isRefresh: Bool) async {
        await ensureGenresLoaded()
        await ensureFavoritesLoaded()
        
        do {
            try await currentPaginator.loadNextPage()
            
            if isRefresh {
                try? await Task.sleep(nanoseconds: 500_000_000)
            } else if let start = initialLoadStart, didCompleteInitialLoad == false {
                let elapsed = Date().timeIntervalSince(start)
                let minDuration: TimeInterval = 1.0
                if elapsed < minDuration {
                    let remaining = UInt64((minDuration - elapsed) * 1_000_000_000)
                    try? await Task.sleep(nanoseconds: remaining)
                }
                initialLoadStart = nil
                didCompleteInitialLoad = true
            }
            
            updateViewState()
        } catch {
            handleError(error)
        }
    }
    
    func handleError(_ error: Error) {
        pendingEmptyTask?.cancel()
        if (error is CancellationError) { return }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled { return }
        
        let wasLoadingMore: Bool = {
            if case .loadingMore = viewState { return true }
            return false
        }()
        if wasLoadingMore {
            loadMoreError.send(error)
        }

        if viewState.currentMovies?.movies.isEmpty == false {
            updateViewState()
        } else {
            viewState = .error(error)
        }
    }
    
    func ensureGenresLoaded() async {
        guard genreMap.isEmpty else { return }
        
        let genres = await getGenresUseCase.execute()
        genreMap = Dictionary(genres.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
    }

    func ensureFavoritesLoaded() async {
        if favoriteIds.isEmpty {
            favoriteIds = await getFavoriteIdsUseCase.execute()
        }
    }
    
    func updateLoadingState(isRefresh: Bool) {
        if isRefresh {
            viewState = .refreshing
        } else if viewState.currentMovies == nil {
            viewState = .loading
        }
    }
    
    func updateViewState() {
        Task {
            let movies = await currentPaginator.items
            let totalPages = await currentPaginator.totalPages
            let currentPage = await currentPaginator.currentPage
            
            let model = MoviesDisplayModel(
                movies: movies,
                totalPages: totalPages,
                currentPage: currentPage
            )
            
            if model.movies.isEmpty {
                let minDisplay: TimeInterval = 0.5
                if shouldSuppressEmptyState, let start = initialLoadStart {
                    let elapsed = Date().timeIntervalSince(start)
                    if elapsed < minDisplay {
                        viewState = .loading
                        shouldSuppressEmptyState = false
                        let remain = UInt64((minDisplay - elapsed) * 1_000_000_000)
                        pendingEmptyTask?.cancel()
                        pendingEmptyTask = Task { [weak self] in
                            try? await Task.sleep(nanoseconds: remain)
                            self?.setEmptyStateIfStillEmpty()
                        }
                        return
                    }
                }
                viewState = .empty(L10n.Empty.noMovies)
            } else {
                pendingEmptyTask?.cancel()
                viewState = .loaded(model)
            }
        }
    }

    @MainActor
    func setEmptyStateIfStillEmpty() {
        Task {
            let movies = await currentPaginator.items
            if movies.isEmpty {
                viewState = .empty(L10n.Empty.noMovies)
            }
        }
    }
}

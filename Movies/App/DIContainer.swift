//
//  DIContainer.swift
//  Movies
//
//  Created by Igor O on 10.09.2025.
//

import Foundation
import UIKit

final class DIContainer {
    
    // MARK: - Config
    private lazy var apiBaseURL: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "TMDB_BASE_URL") as? String else {
            fatalError("TMDB_BASE_URL is missing in Info.plist")
        }
        return Self.validatedAPIBaseURL(value)
    }()
    
    private lazy var apiKey: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String, !value.isEmpty else {
            fatalError("TMDB_API_KEY is missing in Info.plist")
        }
        return value
    }()
    
    private lazy var imageBaseURL: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "TMDB_IMAGE_BASE") as? String else {
            fatalError("TMDB_IMAGE_BASE is missing in Info.plist")
        }
        return Self.validatedImageBaseURL(value)
    }()
    
    // MARK: - Network
    private lazy var tmdbClient: TMDBClient = DefaultTMDBClient(baseURL: apiBaseURL, apiKey: apiKey)
    
    // MARK: - DataSources
    private lazy var movieLocalDataSource: MovieLocalDataSource = DefaultMovieLocalDataSource()
    
    // MARK: - Stores
    private lazy var genresStore: GenresStore = DefaultGenresStore(client: tmdbClient)
    private lazy var favoritesStore: FavoritesStore = DefaultFavoritesStore(coreDataStack: CoreDataStack.shared)
    
    // MARK: - Repositories
    private lazy var movieRepository: MovieRepository = DefaultMovieRepository(client: tmdbClient, localDataSource: movieLocalDataSource)
    private lazy var favoriteMoviesRepository: FavoriteMoviesRepository = DefaultFavoriteMoviesRepository(favoritesStore: favoritesStore, localDataSource: movieLocalDataSource)
    
    // MARK: - Use Cases
    private lazy var getTopRatedMoviesUseCase: GetTopRatedMoviesUseCase = DefaultGetTopRatedMoviesUseCase(movieRepository: movieRepository)
    private lazy var searchMoviesUseCase: SearchMoviesUseCase = DefaultSearchMoviesUseCase(movieRepository: movieRepository)
    private lazy var getFavoriteMoviesUseCase: GetFavoriteMoviesUseCase = DefaultGetFavoriteMoviesUseCase(repository: favoriteMoviesRepository)
    private lazy var getGenresUseCase: GetGenresUseCase = DefaultGetGenresUseCase(genresStore: genresStore)
    private lazy var getImageURLUseCase: GetImageURLUseCase = DefaultGetImageURLUseCase(baseURL: imageBaseURL)
    
    private lazy var filterMoviesUseCase: FilterMoviesUseCase = DefaultFilterMoviesUseCase()
    private lazy var formatGenreNamesUseCase: FormatGenreNamesUseCase = DefaultFormatGenreNamesUseCase()
    private lazy var getNetworkStatusUseCase: GetNetworkStatusUseCase = DefaultGetNetworkStatusUseCase()
    private lazy var getFavoriteIdsUseCase: GetFavoriteIdsUseCase = DefaultGetFavoriteIdsUseCase(store: favoritesStore)
    private lazy var isFavoriteUseCase: IsFavoriteUseCase = DefaultIsFavoriteUseCase(store: favoritesStore)
    private lazy var addFavoriteUseCase: AddFavoriteUseCase = DefaultAddFavoriteUseCase(store: favoritesStore)
    private lazy var removeFavoriteUseCase: RemoveFavoriteUseCase = DefaultRemoveFavoriteUseCase(store: favoritesStore)
    private lazy var toggleFavoriteUseCase: ToggleFavoriteUseCase = DefaultToggleFavoriteUseCase(store: favoritesStore)
    
    private lazy var getMovieDetailsUseCase: GetMovieDetailsUseCase = DefaultGetMovieDetailsUseCase(repository: movieRepository)
    private lazy var getMovieVideosUseCase: GetMovieVideosUseCase = DefaultGetMovieVideosUseCase(repository: movieRepository)

    // MARK: - ViewModels
    @MainActor func makeTopRatedMoviesViewModel() -> TopRatedMoviesViewModel {
        
        return TopRatedMoviesViewModel(
            getTopRatedMoviesUseCase: getTopRatedMoviesUseCase,
            searchMoviesUseCase: searchMoviesUseCase,
            getGenresUseCase: getGenresUseCase,
            formatGenreNamesUseCase: formatGenreNamesUseCase,
            getNetworkStatusUseCase: getNetworkStatusUseCase,
            getFavoriteIdsUseCase: getFavoriteIdsUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            getImageURLUseCase: getImageURLUseCase
        )
    }

    @MainActor func makeMovieDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movieId: movie.id,
            initialTitle: movie.title,
            initialPosterPath: movie.posterPath,
            initialOverview: movie.overview,
            initialReleaseDate: movie.releaseDate,
            initialRating: movie.voteAverage,
            getMovieDetailsUseCase: getMovieDetailsUseCase,
            getMovieVideosUseCase: getMovieVideosUseCase,
            getGenresUseCase: getGenresUseCase,
            formatGenreNamesUseCase: formatGenreNamesUseCase,
            getImageURLUseCase: getImageURLUseCase,
            isFavoriteUseCase: isFavoriteUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase
        )
    }
    
    @MainActor func makeMovieDetailsViewController(movie: Movie) -> UIViewController {
        let viewModel = makeMovieDetailsViewModel(movie: movie)
        let router = MovieDetailsRouter(viewController: nil, diContainer: self)
        let rootView = MovieDetailsContainerView(
            viewModel: viewModel,
            onShowPoster: { router.showPosterFull(imageURL: $0) },
            onShowTrailer: { router.showTrailer(youtubeKey: $0) },
            onClose: { router.close() }
        )
        let hosting = MovieDetailsHostingController(viewModel: viewModel, rootView: rootView)
        hosting.title = movie.title
        router.attach(viewController: hosting)
        return hosting
    }

    func makePosterFullViewController(imageURL: URL) -> PosterFullViewController {
        return PosterFullViewController(imageURL: imageURL)
    }

    @MainActor func makeTopRatedMoviesViewController() -> TopRatedMoviesViewController {
        let factory = TopRatedMoviesUIFactory()
        let router = TopRatedMoviesRouter(viewController: nil, diContainer: self)
        let vc = TopRatedMoviesViewController(
            viewModel: makeTopRatedMoviesViewModel(),
            router: router,
            uiFactory: factory
        )
        router.attach(viewController: vc)
        return vc
    }

    // MARK: - Search
    @MainActor func makeSearchMoviesViewModel() -> SearchMoviesViewModel {
        SearchMoviesViewModel(
            searchMoviesUseCase: searchMoviesUseCase,
            getGenresUseCase: getGenresUseCase,
            formatGenreNamesUseCase: formatGenreNamesUseCase,
            getNetworkStatusUseCase: getNetworkStatusUseCase,
            getFavoriteIdsUseCase: getFavoriteIdsUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            getImageURLUseCase: getImageURLUseCase
        )
    }

    @MainActor func makeSearchMoviesViewController() -> SearchMoviesViewController {
        let vm = makeSearchMoviesViewModel()
        let factory = SearchMoviesUIFactory()
        let router = SearchMoviesRouter(viewController: nil, diContainer: self)
        let vc = SearchMoviesViewController(viewModel: vm, router: router, uiFactory: factory)
        router.attach(viewController: vc)
        return vc
    }

    // MARK: - Favorites
    @MainActor func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            getFavoriteMoviesUseCase: getFavoriteMoviesUseCase,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            formatGenreNamesUseCase: formatGenreNamesUseCase,
            getImageURLUseCase: getImageURLUseCase
        )
    }

    @MainActor func makeFavoritesViewController() -> FavoritesViewController {
        let vm = makeFavoritesViewModel()
        let factory = FavoritesUIFactory()
        let router = FavoritesRouter(viewController: nil, diContainer: self)
        let vc = FavoritesViewController(viewModel: vm, router: router, uiFactory: factory)
        router.attach(viewController: vc)
        return vc
    }
}

// MARK: - Validation helpers
private extension DIContainer {
    static func validatedAPIBaseURL(_ base: String) -> String {
        guard !base.isEmpty else { return base }
        guard let components = URLComponents(string: base),
              let scheme = components.scheme, !scheme.isEmpty,
              let host = components.host, !host.isEmpty else {
            _ = base
            return base
        }
        return base
    }
    
    static func validatedImageBaseURL(_ base: String) -> String {
        guard !base.isEmpty else { return base }
        guard let components = URLComponents(string: base),
              let scheme = components.scheme, !scheme.isEmpty,
              let host = components.host, !host.isEmpty else {
            _ = base
            return base.hasSuffix("/") ? base : base + "/"
        }
        if base.hasSuffix("/") { return base }
        return base + "/"
    }
}

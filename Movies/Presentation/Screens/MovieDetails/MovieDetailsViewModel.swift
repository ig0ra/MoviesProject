//
//  MovieDetailsViewModel.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import Foundation
import Combine

@MainActor
final class MovieDetailsViewModel: ObservableObject {
    enum NavigationEvent {
        case showPosterFull(URL)
    }

    // MARK: - Properties
    @Published private(set) var movieDetails: MovieDetails?
    @Published private(set) var trailerVideo: Video?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error? = nil
    @Published private(set) var isOnline: Bool = true
    @Published private(set) var isFavorite: Bool = false

    let navigationEvent = PassthroughSubject<NavigationEvent, Never>()

    private let movieId: Int
    private let initialTitle: String
    private let initialPosterPath: String?
    private let initialOverview: String
    private let initialReleaseDate: String?
    private let initialRating: Double
    private let getMovieDetailsUseCase: GetMovieDetailsUseCase
    private let getMovieVideosUseCase: GetMovieVideosUseCase
    private let getGenresUseCase: GetGenresUseCase
    private let formatGenreNamesUseCase: FormatGenreNamesUseCase
    private let getImageURLUseCase: GetImageURLUseCase
    private let isFavoriteUseCase: IsFavoriteUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private var genreMap: [Int: String] = [:]
    private var fetchDetailsTask: Task<Void, Never>?

    // MARK: - Initialization
    init(
        movieId: Int,
        initialTitle: String,
        initialPosterPath: String?,
        initialOverview: String,
        initialReleaseDate: String?,
        initialRating: Double,
        getMovieDetailsUseCase: GetMovieDetailsUseCase,
        getMovieVideosUseCase: GetMovieVideosUseCase,
        getGenresUseCase: GetGenresUseCase,
        formatGenreNamesUseCase: FormatGenreNamesUseCase,
        getImageURLUseCase: GetImageURLUseCase,
        isFavoriteUseCase: IsFavoriteUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase
    ) {
        self.movieId = movieId
        self.initialTitle = initialTitle
        self.initialPosterPath = initialPosterPath
        self.initialOverview = initialOverview
        self.initialReleaseDate = initialReleaseDate
        self.initialRating = initialRating
        self.getMovieDetailsUseCase = getMovieDetailsUseCase
        self.getMovieVideosUseCase = getMovieVideosUseCase
        self.getGenresUseCase = getGenresUseCase
        self.formatGenreNamesUseCase = formatGenreNamesUseCase
        self.getImageURLUseCase = getImageURLUseCase
        self.isFavoriteUseCase = isFavoriteUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        Task { [weak self] in
            guard let self = self else { return }
            let fav = await self.isFavoriteUseCase.execute(id: movieId)
            await MainActor.run { self.isFavorite = fav }
        }
    }

    deinit {
        fetchDetailsTask?.cancel()
    }

    // MARK: - Public Methods
    func fetchMovieDetails() {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        fetchDetailsTask = Task { [weak self] in
            guard let self = self else { return }

            await self.fetchGenresIfNeeded()

            do {
                let details = try await self.fetchMovieDetailsData()
                await MainActor.run { self.movieDetails = details }
            } catch {
                await MainActor.run { self.error = error }
            }

            let trailer = await self.fetchTrailerVideo()
            await MainActor.run { self.trailerVideo = trailer }

            await MainActor.run { self.isLoading = false }
        }
    }

    func genreNames(for movieDetails: MovieDetails) -> String {
        let ids = movieDetails.genres.map { $0.id }
        let names = formatGenreNamesUseCase.execute(genreIds: ids, genreMap: genreMap)
        return names.joined(separator: ", ")
    }

    func getPosterURL(with posterPath: String, size: ImageSize) -> URL {
        getImageURLUseCase.execute(with: posterPath, size: size)
    }
    
    var displayTitle: String {
        movieDetails?.title ?? initialTitle
    }

    var displayOverview: String? {
        let overview = movieDetails?.overview ?? initialOverview
        let trimmed = overview.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var posterPath: String? {
        movieDetails?.posterPath ?? initialPosterPath
    }

    var ratingLabelText: String {
        let value = movieDetails?.voteAverage ?? initialRating
        if value.isNaN { return "-" }
        return value.truncatingRemainder(dividingBy: 1).isZero ? String(Int(value)) : String(format: "%.1f", value)
    }

    var releaseDateLabelText: String? {
        guard let dateString = (movieDetails?.releaseDate ?? initialReleaseDate)?.trimmingCharacters(in: .whitespacesAndNewlines),
              let date = Self.inputDateFormatter.date(from: dateString) else { return nil }
        return Self.outputDateFormatter.string(from: date).lowercased(with: Locale.current)
    }

    func toggleFavorite() {
        Task { [weak self] in
            guard let self = self else { return }
            let newValue = await self.toggleFavoriteUseCase.execute(id: self.movieId)
            await MainActor.run { self.isFavorite = newValue }
        }
    }

    func updateNetworkStatus(isOnline: Bool) {
        self.isOnline = isOnline
    }

    func didTapPoster() {
        guard let details = movieDetails, let posterPath = details.posterPath else { return }
        let imageURL = getPosterURL(with: posterPath, size: .original)
        navigationEvent.send(.showPosterFull(imageURL))
    }

    // MARK: - Private Methods
    private func fetchGenresIfNeeded() async {
        if genreMap.isEmpty {
            let genres = await getGenresUseCase.execute()
            genreMap = Dictionary(genres.map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
        }
    }

    private func fetchMovieDetailsData() async throws -> MovieDetails {
        try await getMovieDetailsUseCase.execute(id: movieId)
    }

    private func fetchTrailerVideo() async -> Video? {
        do {
            let videos = try await getMovieVideosUseCase.execute(id: movieId)
            return videos.first(where: { $0.site == "YouTube" && $0.type == "Trailer" })
        } catch {
            return nil
        }
    }
}

private extension MovieDetailsViewModel {
    static let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale.autoupdatingCurrent
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
}

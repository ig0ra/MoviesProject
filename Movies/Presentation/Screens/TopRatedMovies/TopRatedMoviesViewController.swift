//
//  TopRatedMoviesViewController.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit
import Combine

final class TopRatedMoviesViewController: UIViewController {
    private enum Constants {
        static let refreshControlHeight: CGFloat = 60.0
        static let offlineBannerVisibleHeight: CGFloat = 32
        static let bannerAnimationDuration: TimeInterval = 0.25
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var offlineBannerView: UIView!
    @IBOutlet private weak var offlineInfoLabel: UILabel!
    @IBOutlet private weak var offlineBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerContainer: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private let viewModel: TopRatedMoviesViewModel
    private let router: TopRatedMoviesRouting
    private let uiFactory: TopRatedMoviesUIFactory
    private var cancellables = Set<AnyCancellable>()
    private let headerView = TopRatedHeaderView()
    private let themeManager = ThemeManager()

    private lazy var customRefreshControl = uiFactory.makeCustomRefreshControl()
    private lazy var emptyStateLabel = uiFactory.makeEmptyStateLabel()

    private var collectionManager: TopRatedMoviesCollectionManager!
    private var displayModel: MoviesDisplayModel?
    private var movieById: [Int: Movie] = [:]

    init(viewModel: TopRatedMoviesViewModel, router: TopRatedMoviesRouting, uiFactory: TopRatedMoviesUIFactory) {
        self.viewModel = viewModel
        self.router = router
        self.uiFactory = uiFactory
        super.init(nibName: "TopRatedMoviesViewController", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        applyTheme(themeManager.currentTheme)
        // Mark: initial loader with system indicator
        emptyStateLabel.isHidden = true
        activityIndicator.startAnimating()
        collectionView.isHidden = true
        viewModel.loadInitialData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        applyTheme(themeManager.currentTheme)
        viewModel.reloadFavorites()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Setup
private extension TopRatedMoviesViewController {
    func setupUI() {
        setupView()
        setupHeader()
        setupCollectionView()
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        offlineInfoLabel.text = L10n.Network.offlineCached
        offlineInfoLabel.textColor = .secondaryLabel
    }

    func setupHeader() {
        headerContainer.backgroundColor = .clear
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.configure(title: L10n.TopRated.headerTitle)
        headerView.onFavoritesTapped = { [weak self] in
            self?.favoritesTapped()
        }
        headerView.onSearchTapped = { [weak self] in
            self?.searchTapped()
        }
        headerView.onToggleTheme = { [weak self] in
            self?.toggleTheme()
        }
        headerView.updateThemeIcon(theme: themeManager.currentTheme)
        headerContainer.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])
    }

    func setupCollectionView() {
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.backgroundColor = .clear
        collectionManager = TopRatedMoviesCollectionManager(
            collectionView: collectionView,
            emptyStateLabel: emptyStateLabel,
            refreshControl: customRefreshControl,
            refreshHeight: Constants.refreshControlHeight
        )
        wireCollectionCallbacks()
        collectionView.backgroundView = emptyStateLabel
    }
    
    func setupBindings() {
        bindViewState()
        bindNavigation()
        bindNetworkStatus()
        bindLoadMoreError()
    }
    
    func bindViewState() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if let model = state.currentMovies {
                    self?.displayModel = model
                    self?.updateMovieCache(with: model.movies)
                }
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)
    }
    
    func bindNavigation() {
        viewModel.navigationEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleNavigationEvent(event)
            }
            .store(in: &cancellables)
    }
    
    func bindNetworkStatus() {
        viewModel.$isNetworkAvailable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                self?.setOfflineBannerVisible(!isAvailable)
            }
            .store(in: &cancellables)
    }

    func bindLoadMoreError() {
        viewModel.loadMoreError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                let message = L10n.Common.errorPrefix + ErrorPresenter.message(for: error)
                self?.collectionManager.showLoadingMoreError(message: message)
            }
            .store(in: &cancellables)
    }
    
    func wireCollectionCallbacks() {
        collectionManager.onNearEnd = { [weak self] in
            guard let self = self, let movies = self.displayModel?.movies else { return }
            self.viewModel.loadNextPageIfNeeded(currentIndex: movies.count - 1)
        }
        collectionManager.cellViewModelProvider = { [weak self] id in
            guard let self = self, let movie = self.movieById[id] else { return nil }
            return self.viewModel.createCellViewModel(for: movie)
        }
        collectionManager.onSelectMovieId = { [weak self] id in
            self?.viewModel.selectMovie(withId: id)
        }
        collectionManager.onCancelPrefetch = { [weak self] in
            self?.viewModel.cancelPrefetchIfNeeded()
        }
        collectionManager.onRefresh = { [weak self] in
            self?.viewModel.refresh()
        }
        collectionManager.onRetryLoadingMore = { [weak self] in
            self?.viewModel.retryLoadMore()
        }
    }
}

// MARK: - UI Updates
private extension TopRatedMoviesViewController {
    func updateUI(for state: ViewState<MoviesDisplayModel>) {
        switch state {
        case .idle:
            break
            
        case .loading:
            activityIndicator.startAnimating()
            collectionView.isHidden = true
            emptyStateLabel.isHidden = true
            
        case .refreshing:
            if !customRefreshControl.isRefreshing {
                activityIndicator.startAnimating()
                collectionView.isHidden = true
                emptyStateLabel.isHidden = true
            }
            
        case .loadingMore:
            guard let movies = displayModel?.movies else { return }
            collectionManager.applyLoadingMoreSnapshot(currentIds: movies.map { $0.id })
            
        case .loaded(let model):
            collectionManager.setLoadingMore(false)
            collectionManager.setRefreshing(false)
            activityIndicator.stopAnimating()
            emptyStateLabel.isHidden = true
            collectionView.isHidden = false
            collectionManager.clearLoadingMoreState()
            updateMovieCache(with: model.movies)
            collectionManager.applySnapshot(with: model.movies.map { $0.id }, animatingDifferences: true)
            collectionManager.resetContentInset()
            collectionManager.reloadAllItems()
            
        case .empty(let message):
            collectionManager.setLoadingMore(false)
            collectionManager.setRefreshing(false)
            activityIndicator.stopAnimating()
            emptyStateLabel.text = message
            emptyStateLabel.isHidden = false
            movieById.removeAll()
            collectionManager.applyEmptySnapshot()
            collectionView.isHidden = false
            collectionManager.resetContentInset()
            
        case .error(let error):
            collectionManager.setLoadingMore(false)
            collectionManager.setRefreshing(false)
            activityIndicator.stopAnimating()
            showError(error)
            collectionManager.resetContentInset()
        }
    }

    func showError(_ error: Error) {
        let msg = ErrorPresenter.message(for: error)
        let errorMessage = L10n.Common.errorPrefix + msg
        showErrorAlert(message: errorMessage)
    }
    
    func showErrorAlert(message: String) {
        showError(message: message, onRetry: { [weak self] in self?.viewModel.refresh() })
    }
    
    func handleNavigationEvent(_ event: TopRatedMoviesViewModel.NavigationEvent) {
        switch event {
        case .showMovieDetails(let movie):
            guard viewModel.isNetworkAvailable else {
                showInfo(title: L10n.Common.errorTitle, message: L10n.Network.offlineMessage)
                return
            }
            router.showMovieDetails(movie)
        }
    }

    private func setOfflineBannerVisible(_ visible: Bool) {
        let target: CGFloat = visible ? Constants.offlineBannerVisibleHeight : 0
        offlineBannerHeightConstraint.constant = target
        UIView.animate(withDuration: Constants.bannerAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func searchTapped() {
        router.showSearch()
    }

    @objc func favoritesTapped() {
        router.showFavorites()
    }
}

private extension TopRatedMoviesViewController {
    func updateMovieCache(with movies: [Movie]) {
        movieById.reserveCapacity(movies.count)
        movieById = Dictionary(movies.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
    }
}

// MARK: - Theme Handling
private extension TopRatedMoviesViewController {
    func toggleTheme() {
        let newTheme = themeManager.toggleTheme()
        applyTheme(newTheme)
    }

    func applyTheme(_ theme: AppTheme) {
        overrideUserInterfaceStyle = theme.userInterfaceStyle
        navigationController?.overrideUserInterfaceStyle = theme.userInterfaceStyle
        view.window?.overrideUserInterfaceStyle = theme.userInterfaceStyle
        headerView.updateThemeIcon(theme: theme)
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .clear
    }
}

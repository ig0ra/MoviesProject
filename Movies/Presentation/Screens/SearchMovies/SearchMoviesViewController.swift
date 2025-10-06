//
//  SearchMoviesViewController.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit
import Combine

final class SearchMoviesViewController: UIViewController {
    private enum Constants {
        static let refreshControlHeight: CGFloat = 60.0
        static let offlineBannerVisibleHeight: CGFloat = 32
        static let bannerAnimationDuration: TimeInterval = 0.25
    }

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var offlineBannerView: UIView!
    @IBOutlet private weak var offlineInfoLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var offlineBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerContainer: UIView!
    @IBOutlet private weak var resultsLabel: UILabel!

    private let viewModel: SearchMoviesViewModel
    private let router: SearchMoviesRouting
    private let uiFactory: SearchMoviesUIFactory
    private var cancellables = Set<AnyCancellable>()

    private lazy var emptyStateLabel = uiFactory.makeEmptyStateLabel()
    private let headerView = SearchHeaderView()
    private var currentQuery: String = ""
    private lazy var customRefreshControl = uiFactory.makeCustomRefreshControl()

    private var collectionManager: TopRatedMoviesCollectionManager!
    private var displayModel: MoviesDisplayModel?
    private var movieById: [Int: Movie] = [:]

    

    init(viewModel: SearchMoviesViewModel, router: SearchMoviesRouting, uiFactory: SearchMoviesUIFactory) {
        self.viewModel = viewModel
        self.router = router
        self.uiFactory = uiFactory
        super.init(nibName: "SearchMoviesViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.reloadFavorites()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

private extension SearchMoviesViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        offlineInfoLabel.text = L10n.Network.offlineCached
        offlineInfoLabel.textColor = .secondaryLabel
        setupHeader()
        resultsLabel.textColor = .label
        resultsLabel.text = L10n.Search.resultsTitle(0)
        resultsLabel.isHidden = true

        

        collectionView.contentInsetAdjustmentBehavior = .automatic
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

        viewModel.navigationEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .showMovieDetails(let movie):
                    self.router.showMovieDetails(movie)
                }
            }
            .store(in: &cancellables)

        viewModel.$isNetworkAvailable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                self?.setOfflineBannerVisible(!isAvailable)
            }
            .store(in: &cancellables)

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
            self?.viewModel.refresh()
        }
    }

    func updateUI(for state: ViewState<MoviesDisplayModel>) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            collectionView.isHidden = true
            emptyStateLabel.isHidden = true
            resultsLabel.isHidden = true
            collectionManager.setRefreshing(false)
        case .loading:
            activityIndicator.startAnimating()
            collectionView.isHidden = true
        case .refreshing:
            if !customRefreshControl.isRefreshing {
                activityIndicator.startAnimating()
                collectionView.isHidden = true
            }
        case .loadingMore:
            guard let movies = displayModel?.movies else { return }
            collectionManager.applyLoadingMoreSnapshot(currentIds: movies.map { $0.id })
        case .loaded(let model):
            collectionManager.setLoadingMore(false)
            collectionManager.setRefreshing(false)
            activityIndicator.stopAnimating()
            emptyStateLabel.attributedText = nil
            emptyStateLabel.text = L10n.Empty.noMoviesSearch
            emptyStateLabel.isHidden = true
            collectionView.isHidden = false
            collectionManager.clearLoadingMoreState()
            updateMovieCache(with: model.movies)
            collectionManager.applySnapshot(with: model.movies.map { $0.id }, animatingDifferences: true)
            collectionManager.resetContentInset()
            collectionManager.reloadAllItems()
            updateResultsLabel(count: model.movies.count)
        case .empty(let message):
            collectionManager.setLoadingMore(false)
            collectionManager.setRefreshing(false)
            activityIndicator.stopAnimating()
            configureEmptyState(message: message)
            emptyStateLabel.isHidden = false
            movieById.removeAll()
            collectionManager.applyEmptySnapshot()
            collectionView.isHidden = false
            collectionManager.resetContentInset()
            updateResultsLabel(count: 0)
        case .error(let error):
            collectionManager.setLoadingMore(false)
            collectionManager.setRefreshing(false)
            activityIndicator.stopAnimating()
            let msg = ErrorPresenter.message(for: error)
            showError(message: L10n.Common.errorPrefix + msg)
            collectionManager.resetContentInset()
        }
    }

    func setOfflineBannerVisible(_ visible: Bool) {
        let target: CGFloat = visible ? Constants.offlineBannerVisibleHeight : 0
        offlineBannerHeightConstraint.constant = target
        UIView.animate(withDuration: Constants.bannerAnimationDuration) { self.view.layoutIfNeeded() }
    }
}

private extension SearchMoviesViewController {
    func updateMovieCache(with movies: [Movie]) {
        movieById.reserveCapacity(movies.count)
        movieById = Dictionary(movies.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
    }

    func setupHeader() {
        headerContainer.backgroundColor = .clear
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        headerView.onQueryChanged = { [weak self] query in
            guard let self = self else { return }
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            self.currentQuery = trimmed
            self.viewModel.searchQuery.send(trimmed)
            if trimmed.count < 3 {
                self.resultsLabel.isHidden = true
            }
        }
        headerView.updatePlaceholder(L10n.TopRated.searchPlaceholder)
        headerView.updateQuery(currentQuery)
        headerContainer.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])
    }

    

    func updateResultsLabel(count: Int) {
        guard currentQuery.count >= 3 else {
            resultsLabel.isHidden = true
            return
        }
        resultsLabel.text = L10n.Search.resultsTitle(count)
        resultsLabel.isHidden = false
    }

    func configureEmptyState(message: String) {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "NoFound")?.withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal)
        attachment.bounds = CGRect(x: 0, y: -10, width: 120, height: 120)
        let attributed = NSMutableAttributedString(attachment: attachment)
        attributed.append(NSAttributedString(string: "\n\n" + message,
                                            attributes: [
                                                .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                .foregroundColor: UIColor.secondaryLabel
                                            ]))
        emptyStateLabel.attributedText = attributed
    }
}

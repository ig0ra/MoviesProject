//
//  FavoritesViewController.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit
import Combine

final class FavoritesViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private let viewModel: FavoritesViewModel
    private let router: FavoritesRouting
    private let uiFactory: FavoritesUIFactory
    private var cancellables = Set<AnyCancellable>()

    private lazy var emptyStateLabel = uiFactory.makeEmptyStateLabel()
    private var collectionManager: TopRatedMoviesCollectionManager!
    private var displayModel: MoviesDisplayModel?
    private var movieById: [Int: Movie] = [:]
    private var lastIds: [Int] = []

    

    init(viewModel: FavoritesViewModel, router: FavoritesRouting, uiFactory: FavoritesUIFactory) {
        self.viewModel = viewModel
        self.router = router
        self.uiFactory = uiFactory
        super.init(nibName: "FavoritesViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.load()
    }
}

private extension FavoritesViewController {
    func setupUI() {
        title = L10n.Favorites.title
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))

        activityIndicator.isHidden = false
        activityIndicator.stopAnimating()

        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionManager = TopRatedMoviesCollectionManager(
            collectionView: collectionView,
            emptyStateLabel: emptyStateLabel,
            refreshControl: TopRatedMoviesUIFactory().makeCustomRefreshControl(),
            refreshHeight: 60
        )
        collectionManager.showsRemoveButton = true

        collectionManager.onRefresh = { [weak self] in self?.viewModel.refresh() }
        collectionManager.onSelectMovieId = { [weak self] id in self?.viewModel.selectMovie(withId: id) }
        collectionManager.onCancelPrefetch = { }
        collectionManager.onNearEnd = { }
        collectionManager.onRemoveFavoriteId = { [weak self] id in
            self?.viewModel.toggleFavorite(id: id)
        }
        collectionView.backgroundView = emptyStateLabel
    }

    func setupBindings() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .idle:
                    break
                case .loading:
                    self.activityIndicator.startAnimating()
                    self.collectionView.isHidden = true
                case .refreshing:
                    self.activityIndicator.startAnimating()
                    self.collectionView.isHidden = true
                case .loadingMore:
                    break
                case .loaded(let model):
                    self.activityIndicator.stopAnimating()
                    self.collectionView.isHidden = false
                    self.emptyStateLabel.isHidden = true
                    self.displayModel = model
                    let newIds = model.movies.map { $0.id }
                    let removed = Set(self.lastIds).subtracting(newIds)
                    let added = Set(newIds).subtracting(self.lastIds)
                    self.updateMovieCache(with: model.movies)
                    if removed.count == 1 && added.isEmpty {
                        self.collectionManager.deleteItems(ids: Array(removed))
                    } else {
                        self.collectionManager.applySnapshot(with: newIds, animatingDifferences: true)
                    }
                    self.lastIds = newIds
                    self.collectionManager.resetContentInset()
                    self.collectionManager.reloadAllItems()
                case .empty(let message):
                    self.activityIndicator.stopAnimating()
                    self.emptyStateLabel.text = message
                    self.emptyStateLabel.isHidden = false
                    self.movieById.removeAll()
                    self.collectionManager.applyEmptySnapshot()
                    self.collectionView.isHidden = false
                    self.collectionManager.resetContentInset()
                case .error(let error):
                    self.activityIndicator.stopAnimating()
                    let msg = ErrorPresenter.message(for: error)
                    self.showError(message: L10n.Common.errorPrefix + msg)
                }
            }
            .store(in: &cancellables)

        viewModel.navigationEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .close:
                    self.router.close()
                case .showMovieDetails(let movie):
                    self.router.showMovieDetails(movie)
                }
            }
            .store(in: &cancellables)
    }

    func updateMovieCache(with movies: [Movie]) {
        movieById = Dictionary(uniqueKeysWithValues: movies.map { ($0.id, $0) })
        collectionManager.cellViewModelProvider = { [weak self] id in
            guard let self = self, let movie = self.movieById[id] else { return nil }
            return self.viewModel.createCellViewModel(for: movie)
        }
    }

    @objc func closeTapped() { viewModel.navigationEvent.send(.close) }
}

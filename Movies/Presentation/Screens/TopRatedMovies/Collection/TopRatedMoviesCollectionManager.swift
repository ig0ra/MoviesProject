//
//  TopRatedMoviesCollectionManager.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

@preconcurrency
fileprivate typealias MoviesDataSource = UICollectionViewDiffableDataSource<Int, Int>
@preconcurrency
fileprivate typealias MoviesSnapshot = NSDiffableDataSourceSnapshot<Int, Int>

@MainActor
final class TopRatedMoviesCollectionManager: NSObject {
    private enum Constants {
        static let estimatedItemHeight: CGFloat = 280
        static let itemSpacing: CGFloat = 0
        static let sectionInterGroupSpacing: CGFloat = 8
        static let sectionHorizontalInset: CGFloat = 8
        static let footerEstimatedHeight: CGFloat = 44
        static let refreshBottomOffset: CGFloat = -10
        static let refreshRevealOffset: CGFloat = -50
        static let animationDuration: TimeInterval = 0.3
    }
    private let collectionView: UICollectionView
    private let emptyStateLabel: UILabel
    private let refreshControl: CustomRefreshControl
    private let refreshHeight: CGFloat
    private let threshold: Int
    private var isLoadingMore: Bool = false
    private var loadMoreErrorMessage: String? = nil
    private var dataSource: MoviesDataSource!

    var onNearEnd: (() -> Void)?
    var onSelectMovieId: ((Int) -> Void)?
    var onCancelPrefetch: (() -> Void)?
    var onRefresh: (() -> Void)?
    var onRetryLoadingMore: (() -> Void)?
    var cellViewModelProvider: ((Int) -> MovieCellViewModel?)?
    var onRemoveFavoriteId: ((Int) -> Void)?
    var showsRemoveButton: Bool = false

    init(collectionView: UICollectionView,
         emptyStateLabel: UILabel,
         refreshControl: CustomRefreshControl,
         refreshHeight: CGFloat,
         threshold: Int = 5) {
        self.collectionView = collectionView
        self.emptyStateLabel = emptyStateLabel
        self.refreshControl = refreshControl
        self.refreshHeight = refreshHeight
        self.threshold = threshold
        super.init()
        setup()
    }
}

// MARK: - Public API
@MainActor
extension TopRatedMoviesCollectionManager {
    func setRefreshing(_ isRefreshing: Bool) {
        refreshControl.isRefreshing = isRefreshing
    }

    func resetContentInset() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.collectionView.contentInset.top = 0
        }
    }

    func applySnapshot(with movieIds: [Int], animatingDifferences: Bool) {
        var snapshot = MoviesSnapshot()
        snapshot.appendSections([0])
        let uniqueIds = uniqueStably(movieIds)
        snapshot.appendItems(uniqueIds, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    func applyEmptySnapshot() {
        var snapshot = MoviesSnapshot()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func applyLoadingMoreSnapshot(currentIds: [Int]) {
        isLoadingMore = true
        loadMoreErrorMessage = nil
        applySnapshot(with: currentIds, animatingDifferences: true)
        updateVisibleFooter()
    }

    func setLoadingMore(_ loading: Bool) {
        isLoadingMore = loading
        updateVisibleFooter()
    }

    func clearLoadingMoreState() {
        loadMoreErrorMessage = nil
        updateVisibleFooter()
    }

    func showLoadingMoreError(message: String) {
        isLoadingMore = false
        loadMoreErrorMessage = message
        updateVisibleFooter()
    }

    func reloadAllItems() {
        var snapshot = dataSource.snapshot()
        let ids = snapshot.itemIdentifiers
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    func deleteItems(ids: [Int]) {
        guard !ids.isEmpty else { return }
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(ids)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Setup
private extension TopRatedMoviesCollectionManager {
    func setup() {
        collectionView.setCollectionViewLayout(makeCompositionalLayout(), animated: false)
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        collectionView.register(LoadingFooterView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                 withReuseIdentifier: LoadingFooterView.reuseIdentifier)

        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundView = emptyStateLabel
        collectionView.addSubview(refreshControl)

        NSLayoutConstraint.activate([
            refreshControl.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            refreshControl.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: Constants.refreshBottomOffset)
        ])

        configureDataSource()
    }

    func configureDataSource() {
        dataSource = MoviesDataSource(collectionView: collectionView) { [weak self] (cv: UICollectionView, indexPath: IndexPath, itemId: Int) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            guard let cell = cv.dequeueReusableCell(
                withReuseIdentifier: MovieCell.reuseIdentifier,
                for: indexPath
            ) as? MovieCell else {
                return nil
            }
            if let vm = self.cellViewModelProvider?(itemId) {
                cell.configure(with: vm)
                cell.showsRemoveButton = self.showsRemoveButton
                if self.showsRemoveButton {
                    cell.onRemoveTapped = { [weak self] in
                        self?.onRemoveFavoriteId?(itemId)
                    }
                } else {
                    cell.onRemoveTapped = nil
                }
            }
            return cell
        }
        dataSource.supplementaryViewProvider = { [weak self] (cv, kind, indexPath) in
            guard let self = self, kind == UICollectionView.elementKindSectionFooter else { return nil }
            let footer = cv.dequeueReusableSupplementaryView(ofKind: kind,
                                                             withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                                                             for: indexPath) as! LoadingFooterView
            footer.configure(isLoading: self.isLoadingMore, errorMessage: self.loadMoreErrorMessage, onRetry: self.onRetryLoadingMore)
            return footer
        }
    }

    func uniqueStably(_ ids: [Int]) -> [Int] {
        var seen = Set<Int>()
        var result: [Int] = []
        result.reserveCapacity(ids.count)
        for id in ids {
            if seen.insert(id).inserted { result.append(id) }
        }
        return result
    }

    // MARK: - Helpers
    func updateVisibleFooter() {
        let visible = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter)
        for view in visible {
            (view as? LoadingFooterView)?.configure(isLoading: isLoadingMore, errorMessage: loadMoreErrorMessage, onRetry: onRetryLoadingMore)
        }
    }

    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        TwoColumnGridLayout.make(
            estimatedItemHeight: Constants.estimatedItemHeight,
            itemSpacing: Constants.itemSpacing,
            sectionInterGroupSpacing: Constants.sectionInterGroupSpacing,
            sectionHorizontalInset: Constants.sectionHorizontalInset,
            footerEstimatedHeight: Constants.footerEstimatedHeight
        )
    }
}

// MARK: - Delegates
extension TopRatedMoviesCollectionManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let displayedCount = collectionView.numberOfItems(inSection: 0)
        if indexPath.item >= max(0, displayedCount - threshold) {
            onNearEnd?()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
        onSelectMovieId?(id)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !refreshControl.isRefreshing {
            let offsetY = scrollView.contentOffset.y
            refreshControl.alpha = (offsetY < Constants.refreshRevealOffset) ? 1 : 0
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < -refreshHeight {
            refreshControl.alpha = 1
            refreshControl.isRefreshing = true
            onRefresh?()
            UIView.animate(withDuration: Constants.animationDuration) {
                scrollView.contentInset.top = self.refreshHeight
            }
        }
    }
}

extension TopRatedMoviesCollectionManager: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let displayedCount = collectionView.numberOfItems(inSection: 0)
        guard displayedCount > 0 else { return }
        let maxIndex = indexPaths.map { $0.item }.max() ?? 0
        if maxIndex >= max(0, displayedCount - threshold) {
            onNearEnd?()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        onCancelPrefetch?()
    }
}

//
//  TopRatedMoviesUIFactory.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class TopRatedMoviesUIFactory {
    private enum Constants {
        static let emptyStateFontSize: CGFloat = 18
        static let footerHeight: CGFloat = 60
        static let offlineBannerFontSize: CGFloat = 13
        static let offlineBannerHorizontalPadding: CGFloat = 12
        static let offlineBannerVerticalPadding: CGFloat = 6
    }
    func makeSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L10n.TopRated.searchPlaceholder
        return searchController
    }
    
    func makeCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        return collectionView
    }
    
    func makeActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    func makeRefreshControl() -> UIRefreshControl {
        return UIRefreshControl()
    }

    func makeCustomRefreshControl() -> CustomRefreshControl {
        let refreshControl = CustomRefreshControl()
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        return refreshControl
    }
    
    func makeEmptyStateLabel() -> UILabel {
        let label = UILabel()
        label.text = L10n.Empty.noMovies
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.emptyStateFontSize, weight: .medium)
        label.isHidden = true
        return label
    }
    
    
    func makeFooterSpinner() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Constants.footerHeight))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = CGPoint(x: footerView.bounds.midX, y: footerView.bounds.midY)
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }

    func makeOfflineBanner() -> UIView {
        let banner = UIView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.backgroundColor = .systemYellow
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Network.offlineCached
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.offlineBannerFontSize, weight: .semibold)
        label.textColor = .label
        banner.addSubview(label)
        let top = label.topAnchor.constraint(equalTo: banner.topAnchor, constant: Constants.offlineBannerVerticalPadding)
        top.priority = .defaultHigh
        let bottom = label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -Constants.offlineBannerVerticalPadding)
        bottom.priority = .defaultHigh
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: Constants.offlineBannerHorizontalPadding),
            label.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -Constants.offlineBannerHorizontalPadding),
            top,
            bottom
        ])
        return banner
    }
}

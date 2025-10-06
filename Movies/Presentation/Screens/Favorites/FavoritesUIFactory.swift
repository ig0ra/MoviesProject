//
//  FavoritesUIFactory.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class FavoritesUIFactory {
    private enum Constants {
        static let emptyStateFontSize: CGFloat = 18
        static let offlineBannerFontSize: CGFloat = 13
        static let offlineBannerHorizontalPadding: CGFloat = 12
        static let offlineBannerVerticalPadding: CGFloat = 6
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
        let v = UIActivityIndicatorView(style: .large)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidesWhenStopped = true
        return v
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
}

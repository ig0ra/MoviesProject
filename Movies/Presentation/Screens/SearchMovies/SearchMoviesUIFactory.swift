//
//  SearchMoviesUIFactory.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class SearchMoviesUIFactory {
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
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        return cv
    }

    func makeActivityIndicator() -> UIActivityIndicatorView {
        let v = UIActivityIndicatorView(style: .large)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidesWhenStopped = true
        return v
    }

    func makeEmptyStateLabel() -> UILabel {
        let l = UILabel()
        l.text = L10n.Empty.noMoviesSearch
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.font = .systemFont(ofSize: Constants.emptyStateFontSize, weight: .medium)
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }

    func makeCustomRefreshControl() -> CustomRefreshControl {
        let rc = CustomRefreshControl()
        rc.translatesAutoresizingMaskIntoConstraints = false
        return rc
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

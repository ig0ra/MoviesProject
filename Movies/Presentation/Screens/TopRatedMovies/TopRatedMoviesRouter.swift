//
//  TopRatedMoviesRouter.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

protocol TopRatedMoviesRouting: AnyObject {
    func showMovieDetails(_ movie: Movie)
    func showSearch()
    func showFavorites()
}

@MainActor
final class TopRatedMoviesRouter: TopRatedMoviesRouting {
    private weak var viewController: UIViewController?
    private let diContainer: DIContainer
    private var favoritesTransitioningDelegate: UIViewControllerTransitioningDelegate?

    init(viewController: UIViewController?, diContainer: DIContainer) {
        self.viewController = viewController
        self.diContainer = diContainer
    }

    func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showMovieDetails(_ movie: Movie) {
        let movieDetailsVC = diContainer.makeMovieDetailsViewController(movie: movie)
        viewController?.navigationController?.pushViewController(movieDetailsVC, animated: true)
    }

    func showSearch() {
        let searchVC = diContainer.makeSearchMoviesViewController()
        viewController?.navigationController?.pushViewController(searchVC, animated: true)
    }

    func showFavorites() {
        let favoritesVC = diContainer.makeFavoritesViewController()
        let nav = UINavigationController(rootViewController: favoritesVC)
        let transitioning = FavoritesTransitioningDelegate()
        self.favoritesTransitioningDelegate = transitioning
        nav.modalPresentationStyle = .custom
        nav.transitioningDelegate = transitioning
        transitioning.attach(to: nav)
        viewController?.present(nav, animated: true)
    }
}

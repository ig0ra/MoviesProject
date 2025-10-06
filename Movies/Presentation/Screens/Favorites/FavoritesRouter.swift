//
//  FavoritesRouter.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

protocol FavoritesRouting: AnyObject {
    func close()
    func showMovieDetails(_ movie: Movie)
}

final class FavoritesRouter: FavoritesRouting {
    private weak var viewController: UIViewController?
    private let diContainer: DIContainer

    init(viewController: UIViewController?, diContainer: DIContainer) {
        self.viewController = viewController
        self.diContainer = diContainer
    }

    func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    func close() {
        viewController?.dismiss(animated: true)
    }

    func showMovieDetails(_ movie: Movie) {
        let vc = diContainer.makeMovieDetailsViewController(movie: movie)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

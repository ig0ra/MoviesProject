//
//  SearchMoviesRouter.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

protocol SearchMoviesRouting: AnyObject {
    func showMovieDetails(_ movie: Movie)
}

final class SearchMoviesRouter: SearchMoviesRouting {
    private weak var viewController: UIViewController?
    private let diContainer: DIContainer

    init(viewController: UIViewController?, diContainer: DIContainer) {
        self.viewController = viewController
        self.diContainer = diContainer
    }

    func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showMovieDetails(_ movie: Movie) {
        let vc = diContainer.makeMovieDetailsViewController(movie: movie)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

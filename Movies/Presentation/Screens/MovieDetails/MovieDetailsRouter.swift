//
//  MovieDetailsRouter.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit
import SafariServices

protocol MovieDetailsRouting: AnyObject {
    func showPosterFull(imageURL: URL)
    func showTrailer(youtubeKey: String)
    func close()
}

final class MovieDetailsRouter: MovieDetailsRouting {
    private enum Constants {
        static let youtubeWatchBase = "https://www.youtube.com/watch?v="
    }
    private weak var viewController: UIViewController?
    private let diContainer: DIContainer

    init(viewController: UIViewController?, diContainer: DIContainer) {
        self.viewController = viewController
        self.diContainer = diContainer
    }

    func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showPosterFull(imageURL: URL) {
        let posterFullVC = diContainer.makePosterFullViewController(imageURL: imageURL)
        let navController = UINavigationController(rootViewController: posterFullVC)
        navController.modalPresentationStyle = .fullScreen
        viewController?.present(navController, animated: true, completion: nil)
    }

    func showTrailer(youtubeKey: String) {
        guard let url = URL(string: Constants.youtubeWatchBase + youtubeKey) else { return }
        let safariVC = SFSafariViewController(url: url)
        viewController?.present(safariVC, animated: true, completion: nil)
    }

    func close() {
        if let nav = viewController?.navigationController {
            nav.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true)
        }
    }
}

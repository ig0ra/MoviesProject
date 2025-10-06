//
//  AppRouter.swift
//  Movies
//
//  Created by Igor O on 21.09.2025.
//

import UIKit

final class AppRouter {
    private let window: UIWindow
    private let diContainer: DIContainer

    init(window: UIWindow, diContainer: DIContainer) {
        self.window = window
        self.diContainer = diContainer
    }

    @MainActor
    func start() {
        let rootVC = diContainer.makeTopRatedMoviesViewController()
        let nav = UINavigationController(rootViewController: rootVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}

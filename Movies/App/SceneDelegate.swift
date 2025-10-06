//
//  SceneDelegate.swift
//  Movies
//
//  Created by Igor O on 02.10.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let diContainer = DIContainer()
    private var appRouter: AppRouter?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let appRouter = AppRouter(window: window, diContainer: diContainer)
        self.appRouter = appRouter
        Task { @MainActor in
            appRouter.start()
        }
    }
}

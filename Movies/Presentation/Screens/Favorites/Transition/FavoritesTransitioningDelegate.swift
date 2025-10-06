//
//  FavoritesTransitioningDelegate.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class FavoritesTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let presentAnimator = FavoritesPresentAnimator()
    private let dismissAnimator = FavoritesDismissAnimator()
    private let interactive = FavoritesInteractiveController()

    func attach(to viewController: UIViewController) {
        interactive.attach(to: viewController)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentAnimator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        dismissAnimator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactive.isInteracting ? interactive : nil
    }
}

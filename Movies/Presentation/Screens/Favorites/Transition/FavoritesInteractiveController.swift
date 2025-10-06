//
//  FavoritesInteractiveController.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class FavoritesInteractiveController: UIPercentDrivenInteractiveTransition {
    private weak var viewController: UIViewController?
    private var pan: UIPanGestureRecognizer?
    private(set) var isInteracting = false

    func attach(to viewController: UIViewController) {
        self.viewController = viewController
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewController.view.addGestureRecognizer(pan)
        self.pan = pan
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view, let vc = viewController else { return }
        let translation = gesture.translation(in: view)
        let progress = max(0, min(1, translation.y / max(1, view.bounds.height)))

        switch gesture.state {
        case .began:
            isInteracting = true
            vc.dismiss(animated: true)
        case .changed:
            update(progress)
        case .ended, .cancelled, .failed:
            let velocity = gesture.velocity(in: view).y
            let shouldFinish = (progress > 0.35) || (velocity > 800)
            shouldFinish ? finish() : cancel()
            isInteracting = false
        default:
            break
        }
    }
}

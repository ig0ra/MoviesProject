//
//  FavoritesDismissAnimator.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class FavoritesDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.28
    private let blurTag = 877_002
    private let scale: CGFloat = 0.96
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { duration }
    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        guard let fromVC = ctx.viewController(forKey: .from),
              let toVC = ctx.viewController(forKey: .to) else { return }
        let container = ctx.containerView
        let fromView = fromVC.view!
        let toView = toVC.view!

        let reduceMotion = UIAccessibility.isReduceMotionEnabled
        let blur = container.viewWithTag(blurTag) as? UIVisualEffectView

        let animations = {
            blur?.alpha = 0
            blur?.effect = nil
            fromView.frame = container.bounds.offsetBy(dx: 0, dy: container.bounds.height)
            if !reduceMotion { toView.transform = .identity }
        }

        if reduceMotion {
            UIView.animate(withDuration: 0.18, animations: animations) { _ in
                blur?.removeFromSuperview()
                ctx.completeTransition(!ctx.transitionWasCancelled)
            }
        } else {
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn]) {
                animations()
            } completion: { _ in
                blur?.removeFromSuperview()
                ctx.completeTransition(!ctx.transitionWasCancelled)
            }
        }
    }
}

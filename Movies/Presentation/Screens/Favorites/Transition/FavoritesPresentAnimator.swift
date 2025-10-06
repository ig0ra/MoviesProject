//
//  FavoritesPresentAnimator.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class FavoritesPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.45
    private let blurTag = 877_002
    private let scale: CGFloat = 0.96

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { duration }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        guard let toVC = ctx.viewController(forKey: .to),
              let fromVC = ctx.viewController(forKey: .from) else { return }
        let container = ctx.containerView
        let toView = toVC.view!
        let fromView = fromVC.view!

        let reduceMotion = UIAccessibility.isReduceMotionEnabled

        let blur = UIVisualEffectView(effect: nil)
        blur.frame = container.bounds
        blur.tag = blurTag
        blur.alpha = 0

        container.addSubview(blur)
        container.addSubview(toView)

        let targetFrame: CGRect = {
            let b = container.bounds
            if b.width >= 700 {
                let w = min(720, b.width * 0.88)
                let x = (b.width - w) / 2
                return CGRect(x: x, y: b.minY, width: w, height: b.height)
            }
            return b
        }()

        toView.frame = targetFrame.offsetBy(dx: 0, dy: container.bounds.height)
        toView.layer.masksToBounds = true
        toView.layer.cornerRadius = targetFrame.width < container.bounds.width ? 16 : 16

        let animations = {
            if !reduceMotion {
                fromView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                blur.effect = UIBlurEffect(style: .systemChromeMaterial)
                blur.alpha = 1
            }
            toView.frame = targetFrame
        }

        if reduceMotion {
            UIView.animate(withDuration: 0.22, animations: animations) { _ in
                ctx.completeTransition(!ctx.transitionWasCancelled)
            }
        } else {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 0.88,
                           initialSpringVelocity: 0.7,
                           options: [.curveEaseOut]) {
                animations()
            } completion: { _ in
                ctx.completeTransition(!ctx.transitionWasCancelled)
            }
        }
    }
}

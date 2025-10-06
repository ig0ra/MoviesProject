//
//  AlertPresenter.swift
//  Movies
//
//  Generic alert helpers as UIViewController extension
//

//
//  AlertPresenter.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

struct AlertAction {
    let title: String
    let style: UIAlertAction.Style
    let isPreferred: Bool
    let handler: (() -> Void)?

    init(title: String, style: UIAlertAction.Style = .default, isPreferred: Bool = false, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.isPreferred = isPreferred
        self.handler = handler
    }
}

enum PopoverAnchor {
    case barButton(UIBarButtonItem)
    case view(UIView, rect: CGRect?)
}

extension UIViewController {
    @discardableResult
    func presentAlert(title: String?,
                      message: String?,
                      style: UIAlertController.Style = .alert,
                      actions: [AlertAction],
                      anchor: PopoverAnchor? = nil) -> UIAlertController {
        let presentBlock = {
            let alert = UIAlertController(title: title, message: message, preferredStyle: style)
            for action in actions {
                let uiAction = UIAlertAction(title: action.title, style: action.style) { _ in
                    action.handler?()
                }
                alert.addAction(uiAction)
                if action.isPreferred { alert.preferredAction = uiAction }
            }

            if style == .actionSheet, let popover = alert.popoverPresentationController {
                switch anchor {
                case .barButton(let item):
                    popover.barButtonItem = item
                case .view(let view, let rect):
                    popover.sourceView = view
                    if let rect = rect {
                        popover.sourceRect = rect
                    } else {
                        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                    }
                case .none:
                    popover.sourceView = self.view
                    popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                }
            }

            let presenter = self.topMostPresenter()
            presenter.present(alert, animated: true)
            return alert
        }

        if Thread.isMainThread {
            return presentBlock()
        } else {
            var alertRef: UIAlertController!
            DispatchQueue.main.sync {
                alertRef = presentBlock()
            }
            return alertRef
        }
    }

    func showError(message: String,
                   title: String = L10n.Common.errorTitle,
                   okTitle: String = L10n.Common.ok,
                   retryTitle: String = L10n.Common.retry,
                   onRetry: (() -> Void)? = nil) {
        var actions: [AlertAction] = [
            AlertAction(title: okTitle, style: .default)
        ]
        if let onRetry = onRetry {
            actions.append(AlertAction(title: retryTitle, style: .default, isPreferred: true, handler: onRetry))
        }
        _ = presentAlert(title: title, message: message, style: .alert, actions: actions)
    }

    @discardableResult
    func showInfo(title: String? = nil,
                  message: String,
                  okTitle: String = L10n.Common.ok) -> UIAlertController {
        let actions = [AlertAction(title: okTitle, style: .default, isPreferred: true)]
        return presentAlert(title: title, message: message, style: .alert, actions: actions)
    }

    @discardableResult
    func confirm(title: String?,
                 message: String?,
                 confirmTitle: String = L10n.Common.ok,
                 cancelTitle: String = L10n.Common.cancel,
                 onConfirm: @escaping () -> Void) -> UIAlertController {
        let actions = [
            AlertAction(title: cancelTitle, style: .cancel),
            AlertAction(title: confirmTitle, style: .default, isPreferred: true, handler: onConfirm)
        ]
        return presentAlert(title: title, message: message, style: .alert, actions: actions)
    }

    @discardableResult
    func showActionSheet(title: String?,
                         message: String? = nil,
                         actions: [AlertAction],
                         anchor: PopoverAnchor) -> UIAlertController {
        return presentAlert(title: title, message: message, style: .actionSheet, actions: actions, anchor: anchor)
    }

    func presentAlertAsync(title: String?,
                           message: String?,
                           style: UIAlertController.Style = .alert,
                           actionTitles: [String],
                           cancelIndex: Int? = nil,
                           anchor: PopoverAnchor? = nil) async -> Int? {
        await withCheckedContinuation { continuation in
            let actions: [AlertAction] = actionTitles.enumerated().map { (index, title) in
                let style: UIAlertAction.Style = (index == cancelIndex) ? .cancel : .default
                return AlertAction(title: title, style: style, isPreferred: index == 0) {
                    continuation.resume(returning: index)
                }
            }
            _ = presentAlert(title: title, message: message, style: style, actions: actions, anchor: anchor)
        }
    }

    private func topMostPresenter() -> UIViewController {
        var presenter: UIViewController = self
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        return presenter
    }
}

//
//  NetworkAlertManager.swift
//  Movies
//
//  Created by Igor O on 11.09.2025.
//

import UIKit
import Combine

final class NetworkAlertManager {
    private var cancellables = Set<AnyCancellable>()
    private var networkAlert: UIAlertController?
    private weak var window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
        setupNetworkMonitoring()
    }

    private func setupNetworkMonitoring() {
        NetworkMonitor.shared.isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if !isConnected {
                    self.showOfflineAlert()
                } else {
                    self.dismissOfflineAlert()
                }
            }
            .store(in: &cancellables)
    }

    private func showOfflineAlert() {
        guard networkAlert == nil else { return } 

        let alert = UIAlertController(
            title: L10n.Common.errorTitle,
            message: L10n.Network.offlineMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))

        var topController = window?.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        topController?.present(alert, animated: true) { [weak self] in
            self?.networkAlert = alert
        }
    }

    private func dismissOfflineAlert() {
        networkAlert?.dismiss(animated: true) { [weak self] in
            self?.networkAlert = nil
        }
    }
}

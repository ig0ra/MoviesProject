//
//  MovieDetailsHostingController.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import SwiftUI
import Combine
import UIKit

final class MovieDetailsHostingController: UIHostingController<MovieDetailsContainerView> {
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: MovieDetailsViewModel, rootView: MovieDetailsContainerView) {
        super.init(rootView: rootView)
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        viewModel.$movieDetails
            .compactMap { $0?.title }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.title = title
            }
            .store(in: &cancellables)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

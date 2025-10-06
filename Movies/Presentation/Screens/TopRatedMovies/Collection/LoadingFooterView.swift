//
//  LoadingFooterView.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class LoadingFooterView: UICollectionReusableView {
    static let reuseIdentifier = "LoadingFooterView"
    private enum Constants {
        static let verticalPadding: CGFloat = 8
        static let labelFontSize: CGFloat = 13
        static let retryFontSize: CGFloat = 13
    }

    private let stackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.distribution = .equalCentering
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let spinner: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidesWhenStopped = true
        return v
    }()

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: Constants.labelFontSize, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    private let retryButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(L10n.Common.retry, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: Constants.retryFontSize, weight: .semibold)
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private var onRetry: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.addArrangedSubview(spinner)
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(retryButton)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding)
        ])

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(isLoading: Bool, errorMessage: String?, onRetry: (() -> Void)?) {
        self.onRetry = onRetry
        if isLoading {
            spinner.isHidden = false
            spinner.startAnimating()
            errorLabel.isHidden = true
            retryButton.isHidden = true
        } else if let errorMessage = errorMessage {
            spinner.stopAnimating()
            spinner.isHidden = true
            errorLabel.text = errorMessage
            errorLabel.isHidden = false
            retryButton.isHidden = (onRetry == nil)
        } else {
            spinner.stopAnimating()
            spinner.isHidden = true
            errorLabel.isHidden = true
            retryButton.isHidden = true
        }
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}

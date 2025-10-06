//
//  TopRatedHeaderView.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class TopRatedHeaderView: UIView {
    private enum Constants {
        static let titleFontSize: CGFloat = 30
        static let symbolPointSize: CGFloat = 24
        static let height: CGFloat = 72
        static let topPadding: CGFloat = 8
        static let bottomPadding: CGFloat = 16
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let betweenTitleAndButtons: CGFloat = 16
        static let buttonsSpacing: CGFloat = 18
        static let buttonSize: CGFloat = 44
    }
    var onSearchTapped: (() -> Void)?
    var onFavoritesTapped: (() -> Void)?
    var onToggleTheme: (() -> Void)?

    private let titleLabel = UILabel()
    private let buttonsStack = UIStackView()
    private let favoritesButton = HeaderActionButton()
    private let searchButton = HeaderActionButton()
    private let themeButton = HeaderActionButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func configure(title: String) {
        titleLabel.text = title
        let config = UIImage.SymbolConfiguration(pointSize: Constants.symbolPointSize, weight: .regular)
        let tint = UIColor.label
        favoritesButton.setImage(UIImage(systemName: "star", withConfiguration: config), for: .normal)
        searchButton.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: config), for: .normal)
        favoritesButton.tintColor = tint
        searchButton.tintColor = tint
        themeButton.tintColor = tint
    }

    func updateThemeIcon(theme: AppTheme) {
        let config = UIImage.SymbolConfiguration(pointSize: Constants.symbolPointSize, weight: .regular)
        let symbol = (theme == .light) ? "sun.min" : "moon"
        themeButton.setImage(UIImage(systemName: symbol, withConfiguration: config), for: .normal)
        themeButton.tintColor = .label
    }
}

private extension TopRatedHeaderView {
    func setup() {
        backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .label
        titleLabel.font = UIFont.boldSystemFont(ofSize: Constants.titleFontSize)
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = Constants.buttonsSpacing
        buttonsStack.alignment = .center

        [favoritesButton, searchButton, themeButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
        }

        favoritesButton.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        themeButton.addTarget(self, action: #selector(themeTapped), for: .touchUpInside)

        buttonsStack.addArrangedSubview(favoritesButton)
        buttonsStack.addArrangedSubview(searchButton)
        buttonsStack.addArrangedSubview(themeButton)

        addSubview(titleLabel)
        addSubview(buttonsStack)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.height),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topPadding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leadingPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomPadding),
            buttonsStack.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.trailingPadding),
            buttonsStack.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: Constants.betweenTitleAndButtons),
            favoritesButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            favoritesButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            searchButton.widthAnchor.constraint(equalTo: favoritesButton.widthAnchor),
            searchButton.heightAnchor.constraint(equalTo: favoritesButton.heightAnchor),
            themeButton.widthAnchor.constraint(equalTo: favoritesButton.widthAnchor),
            themeButton.heightAnchor.constraint(equalTo: favoritesButton.heightAnchor)
        ])
    }

    @objc func searchTapped() {
        onSearchTapped?()
    }

    @objc func favoritesTapped() {
        onFavoritesTapped?()
    }

    @objc func themeTapped() {
        onToggleTheme?()
    }
}

private final class HeaderActionButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        adjustsImageWhenHighlighted = false
        backgroundColor = .clear
        contentEdgeInsets = .zero
        clipsToBounds = true
    }

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }
}

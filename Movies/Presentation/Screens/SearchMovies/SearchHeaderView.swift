//
//  SearchHeaderView.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class SearchHeaderView: UIView {
    private enum Constants {
        static let iconPointSize: CGFloat = 24
        static let backButtonEdgeInset: CGFloat = 10
        static let backButtonLeading: CGFloat = 8
        static let backButtonTop: CGFloat = 8
        static let backButtonWidth: CGFloat = 38
        static let backButtonHeight: CGFloat = 44
        static let titleTrailing: CGFloat = 24
        static let titleSpacing: CGFloat = 4
        static let searchTop: CGFloat = 16
        static let horizontalPadding: CGFloat = 24
        static let searchHeight: CGFloat = 50
        static let searchIconLeading: CGFloat = 16
        static let searchIconSize: CGFloat = 20
        static let textFieldLeading: CGFloat = 12
        static let textFieldTrailing: CGFloat = 16
        static let titleFontSize: CGFloat = 30
        static let placeholderFontSize: CGFloat = 18
        static let textFieldFontSize: CGFloat = 18
    }
    var onBack: (() -> Void)?
    var onQueryChanged: ((String) -> Void)?

    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let searchContainer = UIView()
    private let searchIcon = UIImageView()
    private let textField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func updatePlaceholder(_ placeholder: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.placeholderText,
                .font: UIFont.systemFont(ofSize: Constants.placeholderFontSize, weight: .medium)
            ])
    }

    func updateQuery(_ text: String) {
        guard textField.text != text else { return }
        textField.text = text
    }
}

private extension SearchHeaderView {
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        configureBackButton()
        configureTitleLabel()
        configureSearchField()
        layoutViews()
    }

    func configureBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: Constants.iconPointSize, weight: .bold)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: config)
        
        backButton.setImage(image, for: .normal)
        backButton.tintColor = .label
        backButton.contentEdgeInsets = UIEdgeInsets(top: Constants.backButtonEdgeInset, left: Constants.backButtonEdgeInset, bottom: Constants.backButtonEdgeInset, right: Constants.backButtonEdgeInset)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: Constants.titleFontSize)
        titleLabel.textColor = .label
        titleLabel.text = L10n.Search.title
    }

    func configureSearchField() {
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.backgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor(white: 0.94, alpha: 1)
        }
        searchContainer.layer.cornerRadius = 20

        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.image = UIImage(systemName: "magnifyingglass")
        searchIcon.tintColor = .label

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: Constants.textFieldFontSize, weight: .bold)
        textField.textColor = .label
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .search
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.delegate = self
    }

    func layoutViews() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(searchContainer)
        searchContainer.addSubview(searchIcon)
        searchContainer.addSubview(textField)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.backButtonLeading),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.backButtonTop),
            backButton.widthAnchor.constraint(equalToConstant: Constants.backButtonWidth),
            backButton.heightAnchor.constraint(equalToConstant: Constants.backButtonHeight),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: Constants.titleSpacing),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.titleTrailing),

            searchContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: Constants.searchTop),
            searchContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            searchContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            searchContainer.heightAnchor.constraint(equalToConstant: Constants.searchHeight),
            bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            searchIcon.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: Constants.searchIconLeading),
            searchIcon.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: Constants.searchIconSize),
            searchIcon.heightAnchor.constraint(equalToConstant: Constants.searchIconSize),

            textField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: Constants.textFieldLeading),
            textField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -Constants.textFieldTrailing),
            textField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor)
        ])
    }

    @objc func backTapped() {
        onBack?()
    }

    @objc func textDidChange() {
        onQueryChanged?(textField.text ?? "")
    }
}

extension SearchHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onQueryChanged?(textField.text ?? "")
        return true
    }
}

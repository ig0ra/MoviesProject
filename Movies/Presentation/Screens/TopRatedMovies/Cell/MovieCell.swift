//
//  MovieCell.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit
import SDWebImage

final class MovieCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieCell"
    
    private enum Constants {
        static let cornerRadius: CGFloat = 15
        static let outerPadding: CGFloat = 10
        static let spacingSmall: CGFloat = 6
        static let spacingMedium: CGFloat = 8
        static let titleFontSize: CGFloat = 14
        static let ratingFontSize: CGFloat = 10
        static let posterAspect: CGFloat = 1.5
        static let placeholderSymbolName = "photo"
        static let placeholderSymbolSize: CGFloat = 40
        static let favoriteIconTop: CGFloat = 11
        static let favoriteIconTrailing: CGFloat = 14
        static let favoriteIconSize: CGFloat = 20
        static let starIconPointSize: CGFloat = 18
        static let removeButtonTop: CGFloat = 2
        static let removeButtonTrailing: CGFloat = 2
        static let removeButtonSize: CGFloat = 44
        static let removeIconPointSize: CGFloat = 22
        static let imageFadeDuration: TimeInterval = 0.2
        static let shadowOpacity: Float = 0.1
        static let shadowRadius: CGFloat = 2
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let removeTapScale: CGFloat = 0.85
        static let removeTapDurationDown: TimeInterval = 0.08
        static let removeTapDurationUp: TimeInterval = 0.22
        static let springDamping: CGFloat = 0.6
        static let springVelocity: CGFloat = 0.8
    }

    private var currentMovieId: Int?

    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let favoriteIconView = UIImageView()
    private let removeButton = UIButton(type: .system)
    var onRemoveTapped: (() -> Void)?

    var showsRemoveButton: Bool {
        get { !removeButton.isHidden }
        set {
            removeButton.isHidden = !newValue
            favoriteIconView.isHidden = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        configureShadow()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: MovieCellViewModel) {
        currentMovieId = viewModel.id
        titleLabel.text = viewModel.title
        ratingLabel.text = L10n.Common.ratingPrefix + viewModel.rating
        loadPosterImage(from: viewModel.posterURL)
        let starCfg = UIImage.SymbolConfiguration(pointSize: Constants.starIconPointSize, weight: .bold)
        favoriteIconView.image = UIImage(systemName: "star.fill", withConfiguration: starCfg)
        favoriteIconView.tintColor = viewModel.isFavorite ? .systemYellow : UIColor.white.withAlphaComponent(0.6)
        favoriteIconView.alpha = 1.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.sd_cancelCurrentImageLoad()
        posterImageView.image = nil
        currentMovieId = nil
    }
}

private extension MovieCell {
    func setupLayout() {
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.masksToBounds = true
        configurePosterImageView()
        configureTitleLabel()
        configureRatingLabel()
        configureFavoriteIcon()
        addSubviews()
        setupConstraints()
    }
    
    func configurePosterImageView() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = Constants.cornerRadius
        posterImageView.backgroundColor = .secondarySystemBackground
        posterImageView.isUserInteractionEnabled = true
    }
    
    func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        titleLabel.numberOfLines = 2
    }
    
    func configureRatingLabel() {
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = .systemFont(ofSize: Constants.ratingFontSize, weight: .medium)
    }
    
    func addSubviews() {
        [posterImageView, titleLabel, ratingLabel].forEach { contentView.addSubview($0) }
        posterImageView.addSubview(favoriteIconView)
        contentView.addSubview(removeButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.outerPadding),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.outerPadding),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.outerPadding),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: Constants.posterAspect),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: Constants.spacingMedium),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.outerPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.outerPadding),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.spacingSmall),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.outerPadding),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.outerPadding),
            ratingLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.outerPadding)
        ])

        favoriteIconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteIconView.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: Constants.favoriteIconTop),
            favoriteIconView.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: -Constants.favoriteIconTrailing),
            favoriteIconView.widthAnchor.constraint(equalToConstant: Constants.favoriteIconSize),
            favoriteIconView.heightAnchor.constraint(equalToConstant: Constants.favoriteIconSize)
        ])

        removeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: Constants.removeButtonTop),
            removeButton.trailingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: -Constants.removeButtonTrailing),
            removeButton.widthAnchor.constraint(equalToConstant: Constants.removeButtonSize),
            removeButton.heightAnchor.constraint(equalToConstant: Constants.removeButtonSize)
        ])
    }
    
    func loadPosterImage(from url: URL?) {
        let placeholderImage = makePlaceholderImage()
        guard let url = url else {
            posterImageView.image = placeholderImage
            return
        }
        posterImageView.sd_imageTransition = .fade(duration: Constants.imageFadeDuration)
        posterImageView.sd_setImage(with: url, placeholderImage: placeholderImage, options: [.scaleDownLargeImages, .retryFailed, .continueInBackground])
    }

    func makePlaceholderImage() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: Constants.placeholderSymbolSize, weight: .medium)
        return UIImage(systemName: Constants.placeholderSymbolName, withConfiguration: config)?.withTintColor(.accent, renderingMode: .alwaysOriginal)
    }

    func configureShadow() {
        clipsToBounds = false
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowRadius  = Constants.shadowRadius
        layer.shadowOffset  = Constants.shadowOffset
        layer.shouldRasterize    = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func configureFavoriteIcon() {
        favoriteIconView.contentMode = .scaleAspectFit
        let removeCfg = UIImage.SymbolConfiguration(pointSize: Constants.removeIconPointSize, weight: .bold)
        let removeImg = UIImage(systemName: "xmark.circle.fill", withConfiguration: removeCfg)
        removeButton.setImage(removeImg, for: .normal)
        removeButton.tintColor = .systemRed
        removeButton.contentEdgeInsets = UIEdgeInsets(top: Constants.spacingSmall + 2, left: Constants.spacingSmall + 2, bottom: Constants.spacingSmall + 2, right: Constants.spacingSmall + 2)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        removeButton.isHidden = true
    }

    @objc func removeTapped() {
        let anim = { self.removeButton.transform = CGAffineTransform(scaleX: Constants.removeTapScale, y: Constants.removeTapScale) }
        let restore = { self.removeButton.transform = .identity }
        UIView.animate(withDuration: Constants.removeTapDurationDown, animations: anim) { _ in
            UIView.animate(withDuration: Constants.removeTapDurationUp,
                           delay: 0,
                           usingSpringWithDamping: Constants.springDamping,
                           initialSpringVelocity: Constants.springVelocity,
                           options: [.curveEaseOut],
                           animations: restore,
                           completion: { _ in self.onRemoveTapped?() })
        }
    }
}

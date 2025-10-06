//
//  MovieDetailsSwiftUIView.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import SwiftUI
import Combine
import SDWebImage
import UIKit

struct MovieDetailsContainerView: View {
    @ObservedObject var viewModel: MovieDetailsViewModel
    let onShowPoster: (URL) -> Void
    let onShowTrailer: (String) -> Void
    let onClose: () -> Void

    @State private var alertMessage: String?
    @State private var isShowingAlert = false
    @State private var hasAppeared = false

    var body: some View {
        GeometryReader { geometry in
            content(safeAreaTop: geometry.safeAreaInsets.top)
                .edgesIgnoringSafeArea(.top)
        }
    }

    private func content(safeAreaTop: CGFloat) -> some View {
        let inset = max(safeAreaTop, 0)
        return MovieDetailsView(
            viewModel: viewModel,
            onShowPoster: onShowPoster,
            onShowTrailer: onShowTrailer,
            onClose: onClose,
            safeAreaTopInset: inset
        )
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            viewModel.fetchMovieDetails()
        }
        .onReceive(viewModel.navigationEvent) { event in
            if case let .showPosterFull(url) = event, viewModel.isOnline {
                onShowPoster(url)
            }
        }
        .onReceive(viewModel.$error.compactMap { $0 }) { error in
            alertMessage = L10n.Common.errorPrefix + ErrorPresenter.message(for: error)
            isShowingAlert = true
        }
        .onReceive(NetworkMonitor.shared.isConnected) { isConnected in
            viewModel.updateNetworkStatus(isOnline: isConnected)
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text(L10n.Common.errorTitle),
                message: Text(alertMessage ?? ""),
                primaryButton: .default(Text(L10n.Common.retry)) {
                    viewModel.fetchMovieDetails()
                },
                secondaryButton: .cancel(Text(L10n.Common.ok))
            )
        }
    }
}

private enum DetailsConstants {
    static let posterWidth: CGFloat = 220
    static let posterHeight: CGFloat = 330
    static let posterCornerRadius: CGFloat = 24
    static let favoritesButtonColor = Color(red: 0.99, green: 0.85, blue: 0.30)
    static let backIconSize: CGFloat = 24
    static let backButtonWidth: CGFloat = 44
    static let backButtonHeight: CGFloat = 44
    static let backLeadingPadding: CGFloat = -14
    static let containerHorizontalPadding: CGFloat = 24
    static let containerTopPadding: CGFloat = 53
    static let containerBottomPadding: CGFloat = 40
    static let placeholderSymbolSize: CGFloat = 40
    static let ratingFontSize: CGFloat = 10
    static let titleFontSize: CGFloat = 30
    static let bodyFontSize: CGFloat = 12
    static let lineSpacing: CGFloat = 6
    static let buttonsSpacing: CGFloat = 16
    static let springResponse: Double = 0.4
    static let springDampingFraction: Double = 0.75
    static let springBlendDuration: Double = 0.2
}

struct MovieDetailsView: View {
    @ObservedObject var viewModel: MovieDetailsViewModel
    let onShowPoster: (URL) -> Void
    let onShowTrailer: (String) -> Void
    let onClose: () -> Void
    let safeAreaTopInset: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    posterSection
                    ratingSection
                        .padding(.top, -16)
                    overviewSection
                    releaseDateSection
                    buttonsSection
                }
                .padding(.horizontal, DetailsConstants.containerHorizontalPadding)
                .padding(.top, DetailsConstants.containerTopPadding)
                .padding(.bottom, DetailsConstants.containerBottomPadding)
            }

            if viewModel.isLoading {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }
        }
        .background(Color(.systemBackground))
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: DetailsConstants.backIconSize, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: DetailsConstants.backButtonWidth, height: DetailsConstants.backButtonHeight)
                    .contentShape(Rectangle())
            }
            .padding(.leading, DetailsConstants.backLeadingPadding)

            Text(viewModel.displayTitle)
                .font(.system(size: DetailsConstants.titleFontSize, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Spacer()
        }
    }

    private var posterSection: some View {
        HStack {
            Spacer()
            Group {
                if let path = viewModel.posterPath {
                    PosterImageView(
                        url: viewModel.getPosterURL(with: path, size: .w500),
                        size: CGSize(width: DetailsConstants.posterWidth, height: DetailsConstants.posterHeight)
                    )
                    .onTapGesture {
                        guard viewModel.isOnline else { return }
                        let url = viewModel.getPosterURL(with: path, size: .original)
                        onShowPoster(url)
                    }
                } else {
                    RoundedRectangle(cornerRadius: DetailsConstants.posterCornerRadius, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: DetailsConstants.posterWidth, height: DetailsConstants.posterHeight)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: DetailsConstants.placeholderSymbolSize, weight: .regular))
                                .foregroundColor(Color(.tertiaryLabel))
                        )
                }
            }
            Spacer()
        }
    }

    private var ratingSection: some View {
        Text("\(L10n.Common.ratingPrefix)\(viewModel.ratingLabelText)")
            .font(.system(size: DetailsConstants.ratingFontSize, weight: .medium))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var overviewSection: some View {
        Group {
            if let overview = viewModel.displayOverview, !overview.isEmpty {
                Text(overview)
                    .font(.system(size: DetailsConstants.bodyFontSize, weight: .regular))
                    .foregroundColor(.primary)
                    .lineSpacing(DetailsConstants.lineSpacing)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var releaseDateSection: some View {
        Group {
            if let release = viewModel.releaseDateLabelText {
                Text(release)
                    .font(.system(size: DetailsConstants.bodyFontSize, weight: .regular))
                    .foregroundColor(.primary)
            }
        }
    }

    private var buttonsSection: some View {
        VStack(spacing: DetailsConstants.buttonsSpacing) {
            secondaryButton(
                title: L10n.Details.watchTrailer,
                isEnabled: viewModel.isOnline && viewModel.trailerVideo != nil,
                action: {
                    if let key = viewModel.trailerVideo?.key { onShowTrailer(key) }
                }
            )

            Button(action: {
                withAnimation(.spring(response: DetailsConstants.springResponse, dampingFraction: DetailsConstants.springDampingFraction, blendDuration: DetailsConstants.springBlendDuration)) {
                    viewModel.toggleFavorite()
                }
            }) {
                Text(viewModel.isFavorite ? L10n.Details.removeFromFavorites : L10n.Details.addToFavorites)
            }
            .buttonStyle(FavoritesCapsuleButtonStyle(isFavorite: viewModel.isFavorite))
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let v = UIActivityIndicatorView(style: style)
        v.hidesWhenStopped = true
        return v
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

private struct PosterImageView: View {
    let url: URL
    let size: CGSize
    @State private var image: UIImage?
    @State private var currentURL: URL?
    @State private var loadOperation: SDWebImageOperation?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DetailsConstants.posterCornerRadius, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: DetailsConstants.posterCornerRadius, style: .continuous))
        .onAppear { loadIfNeeded(for: url) }
        .onReceive(Just(url)) { loadIfNeeded(for: $0) }
        .onDisappear { cancelLoad() }
    }

    private func loadIfNeeded(for url: URL) {
        if currentURL == url, image != nil { return }
        load(url: url)
    }

    private func load(url: URL) {
        currentURL = url
        cancelLoad()
        loadOperation = SDWebImageManager.shared.loadImage(with: url,
                                           options: [.retryFailed, .scaleDownLargeImages],
                                           progress: nil) { image, _, error, _, _, _ in
            DispatchQueue.main.async {
                guard currentURL == url else { return }
                if let image = image, error == nil {
                    self.image = image
                } else {
                    self.image = nil
                }
                loadOperation = nil
            }
        }
    }

    private func cancelLoad() {
        loadOperation?.cancel()
        loadOperation = nil
    }
}

private struct SecondaryCapsuleButtonStyle: ButtonStyle {
    let isEnabled: Bool
    private enum Constants {
        static let fontSize: CGFloat = 18
        static let verticalPadding: CGFloat = 14
        static let disabledOpacity: Double = 1.0
        static let pressedOpacity: Double = 0.85
        static let strokeWidth: CGFloat = 0
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Constants.fontSize, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.verticalPadding)
            .foregroundColor(isEnabled ? Color(.label) : Color(.tertiaryLabel))
            .background(isEnabled ? Color(.secondarySystemBackground) : Color(.tertiarySystemFill))
            .clipShape(Capsule())
            .opacity(configuration.isPressed && isEnabled ? Constants.pressedOpacity : Constants.disabledOpacity)
    }
}

private extension MovieDetailsView {
    func secondaryButton(title: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
        }
        .buttonStyle(SecondaryCapsuleButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct FavoritesCapsuleButtonStyle: ButtonStyle {
    let isFavorite: Bool
    private enum Constants {
        static let fontSize: CGFloat = 16
        static let verticalPadding: CGFloat = 18
        static let pressedOpacity: Double = 0.85
        static let pressedScale: CGFloat = 0.98
        static let idleScale: CGFloat = 1
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.75
        static let springBlend: Double = 0.2
        static let strokeWidth: CGFloat = 1
    }

    func makeBody(configuration: Configuration) -> some View {
        let base = Capsule()
        return configuration.label
            .font(.system(size: Constants.fontSize, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.verticalPadding)
            .foregroundColor(isFavorite ? Color(.label) : Color(.black))
            .background(
                base.fill(isFavorite ? Color.clear : DetailsConstants.favoritesButtonColor)
            )
            .overlay(
                base.stroke(Color(.label).opacity(isFavorite ? 0.7 : 0), lineWidth: Constants.strokeWidth)
            )
            .opacity(configuration.isPressed ? Constants.pressedOpacity : 1)
            .scaleEffect(configuration.isPressed ? Constants.pressedScale : Constants.idleScale)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .animation(.spring(response: Constants.springResponse, dampingFraction: Constants.springDamping, blendDuration: Constants.springBlend), value: isFavorite)
    }
}

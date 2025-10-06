//
//  CustomRefreshControl.swift
//  Movies
//
//  Created by Igor O on 04.10.2025.
//

import UIKit

final class CustomRefreshControl: UIView {
    private enum Constants {
        static let indicatorYOffset: CGFloat = -30
        static let labelTopSpacing: CGFloat = 20
    }
    
    // MARK: - Properties
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let label = UILabel()
    
    var isRefreshing: Bool = false {
        didSet {
            if isRefreshing {
                startRefreshing()
            } else {
                stopRefreshing()
            }
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        addSubview(activityIndicator)
        addSubview(label)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: Constants.indicatorYOffset),
            
            label.topAnchor.constraint(equalTo: activityIndicator.topAnchor, constant: Constants.labelTopSpacing),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        label.text = L10n.Refresh.pullToRefresh
        label.textColor = .secondaryLabel
    }
    
    // MARK: - Public Methods
    
    func startRefreshing() {
        activityIndicator.startAnimating()
        label.text = L10n.Refresh.refreshing
    }
    
    func stopRefreshing() {
        activityIndicator.stopAnimating()
        label.text = L10n.Refresh.pullToRefresh
    }
}

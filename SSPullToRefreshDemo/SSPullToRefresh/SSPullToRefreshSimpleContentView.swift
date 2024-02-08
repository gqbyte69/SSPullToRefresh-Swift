//
//  SSPullToRefreshSimpleContentView.swift
//  SSPullToRefreshDemo
//
//  Created by Adonis Dumadapat on 1/30/24.
//

import UIKit

class SSPullToRefreshSimpleContentView: UIView, SSPullToRefreshContentViewProtocol {
    private(set) var statusLabel: UILabel!
    private(set) var activityIndicatorView: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = bounds.size
        statusLabel.frame = CGRect(x: 20.0, y: round((size.height - 30.0) / 2.0), width: size.width - 40.0, height: 30.0)
        activityIndicatorView.frame = CGRect(x: round((size.width - 20.0) / 2.0), y: round((size.height - 20.0) / 2.0), width: 20.0, height: 20.0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
}

// MARK: - Setup

private extension SSPullToRefreshSimpleContentView {
    func setupSubviews() {
        let width = bounds.size.width

        statusLabel = UILabel(frame: CGRect(x: 0.0, y: 14.0, width: width, height: 20.0))
        statusLabel.autoresizingMask = [.flexibleWidth]
        statusLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        statusLabel.textColor = .black
        statusLabel.backgroundColor = .clear
        statusLabel.textAlignment = .center
        addSubview(statusLabel)

        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.frame = CGRect(x: 30.0, y: 25.0, width: 20.0, height: 20.0)
        addSubview(activityIndicatorView)
    }
}

// MARK: - SSPullToRefreshContentViewProtocol

extension SSPullToRefreshSimpleContentView {
    func setState(_ state: SSPullToRefreshViewState, withPullToRefreshView view: SSPullToRefreshView) {
        switch state {
        case .ready:
            statusLabel.text = NSLocalizedString("Release to refresh", comment: "")
            activityIndicatorView.startAnimating()
            activityIndicatorView.alpha = 0.0
        case .normal:
            statusLabel.text = NSLocalizedString("Pull down to refresh", comment: "")
            statusLabel.alpha = 1.0
            activityIndicatorView.stopAnimating()
            activityIndicatorView.alpha = 0.0
        case .loading:
            statusLabel.alpha = 0.0
            activityIndicatorView.startAnimating()
            activityIndicatorView.alpha = 1.0
        case .closing:
            statusLabel.text = nil
            activityIndicatorView.alpha = 0.0
        }
    }
}

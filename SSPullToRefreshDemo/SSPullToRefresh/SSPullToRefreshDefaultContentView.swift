//
//  SSPullToRefreshDefaultContentView.swift
//  SSPullToRefreshDemo
//
//  Created by Adonis Dumadapat on 1/30/24.
//

import UIKit

class SSPullToRefreshDefaultContentView: UIView {
    private(set) var statusLabel: UILabel!
    private(set) var lastUpdatedAtLabel: UILabel!
    private(set) var activityIndicatorView: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
}

// MARK: - Setup

private extension SSPullToRefreshDefaultContentView {
    func setupSubviews() {
        let width = bounds.size.width

        statusLabel = UILabel(frame: CGRect(x: 0.0, y: 14.0, width: width, height: 20.0))
        statusLabel.autoresizingMask = [.flexibleWidth]
        statusLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        statusLabel.textColor = .black
        statusLabel.backgroundColor = .clear
        statusLabel.textAlignment = .center
        addSubview(statusLabel)

        lastUpdatedAtLabel = UILabel(frame: CGRect(x: 0.0, y: 34.0, width: width, height: 20.0))
        lastUpdatedAtLabel.autoresizingMask = [.flexibleWidth]
        lastUpdatedAtLabel.font = UIFont.systemFont(ofSize: 12.0)
        lastUpdatedAtLabel.textColor = .lightGray
        lastUpdatedAtLabel.backgroundColor = .clear
        lastUpdatedAtLabel.textAlignment = .center
        addSubview(lastUpdatedAtLabel)

        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.frame = CGRect(x: 30.0, y: 25.0, width: 20.0, height: 20.0)
        addSubview(activityIndicatorView)
    }
}

// MARK: - SSPullToRefreshContentViewProtocol

extension SSPullToRefreshDefaultContentView: SSPullToRefreshContentViewProtocol {
    func setState(_ state: SSPullToRefreshViewState, withPullToRefreshView view: SSPullToRefreshView) {
        switch state {
        case .ready:
            statusLabel.text = NSLocalizedString("Release to refresh…", comment: "")
            activityIndicatorView.stopAnimating()
        case .normal:
            statusLabel.text = NSLocalizedString("Pull down to refresh…", comment: "")
            activityIndicatorView.stopAnimating()
        case .loading, .closing:
            statusLabel.text = NSLocalizedString("Loading…", comment: "")
            activityIndicatorView.startAnimating()
        }
    }

    func setLastUpdatedAt(
        _ date: Date?,
        withPullToRefreshView view: SSPullToRefreshView
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        if let date = date {
            lastUpdatedAtLabel.text = String(
                format: NSLocalizedString("Last Updated: %@", comment: ""),
                dateFormatter.string(from: date)
            )
        } else {
            lastUpdatedAtLabel.text = nil
        }
    }
}

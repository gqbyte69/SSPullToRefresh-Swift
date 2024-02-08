//
//  SSPullToRefreshContentViewProtocol.swift
//  SSPullToRefreshDemo
//
//  Created by Adonis Dumadapat on 1/30/24.
//

import Foundation

protocol SSPullToRefreshContentViewProtocol {
    func setState(
        _ state: SSPullToRefreshViewState,
        withPullToRefreshView view: SSPullToRefreshView
    )

    func setPullProgress(_ progress: CGFloat)
    func setLastUpdatedAt(
        _ date: Date?,
        withPullToRefreshView view: SSPullToRefreshView
    )
}

// MARK: - Optional protocols

extension SSPullToRefreshContentViewProtocol {
    func setPullProgress(_ progress: CGFloat) {}
    func setLastUpdatedAt(
        _ date: Date?,
        withPullToRefreshView view: SSPullToRefreshView
    ) {}
}

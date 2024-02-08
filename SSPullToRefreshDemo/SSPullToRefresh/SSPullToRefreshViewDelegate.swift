//
//  SSPullToRefreshViewDelegate.swift
//  SSPullToRefreshDemo
//
//  Created by Adonis Dumadapat on 1/30/24.
//

import UIKit

protocol SSPullToRefreshViewDelegate {
    func pullToRefreshViewShouldStartLoading(_ view: SSPullToRefreshView) -> Bool
    func pullToRefreshViewDidStartLoading(_ view: SSPullToRefreshView)
    func pullToRefreshViewDidFinishLoading(_ view: SSPullToRefreshView)
    func pullToRefreshViewLastUpdatedAt(_ view: SSPullToRefreshView) -> Date

    func pullToRefreshView(
        _ view: SSPullToRefreshView,
        didUpdateContentInset contentInset: UIEdgeInsets
    )

    func pullToRefreshView(
        _ view: SSPullToRefreshView,
        willTransitionToState toState: SSPullToRefreshViewState,
        fromState: SSPullToRefreshViewState,
        animated: Bool
    )

    func pullToRefreshView(
        _ view: SSPullToRefreshView,
        didTransitionToState toState: SSPullToRefreshViewState,
        fromState: SSPullToRefreshViewState,
        animated: Bool
    )
}

// MARK: - Optional protocols

extension SSPullToRefreshViewDelegate {
    func pullToRefreshViewShouldStartLoading(_ view: SSPullToRefreshView) -> Bool { true }
    func pullToRefreshViewDidStartLoading(_ view: SSPullToRefreshView) {}
    func pullToRefreshViewDidFinishLoading(_ view: SSPullToRefreshView) {}
    func pullToRefreshViewLastUpdatedAt(_ view: SSPullToRefreshView) -> Date { Date() }

    func pullToRefreshView(
        _ view: SSPullToRefreshView,
        didUpdateContentInset contentInset: UIEdgeInsets
    ) {}

    func pullToRefreshView(
        _ view: SSPullToRefreshView,
        willTransitionToState toState: SSPullToRefreshViewState,
        fromState: SSPullToRefreshViewState,
        animated: Bool
    ) {}

    func pullToRefreshView(
        _ view: SSPullToRefreshView,
        didTransitionToState toState: SSPullToRefreshViewState,
        fromState: SSPullToRefreshViewState,
        animated: Bool
    ) {}
}

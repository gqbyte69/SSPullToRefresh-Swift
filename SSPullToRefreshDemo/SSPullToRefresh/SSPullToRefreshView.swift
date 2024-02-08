//
//  SSPullToRefreshView.swift
//  SSPullToRefreshDemo
//
//  Created by Adonis Dumadapat on 1/30/24.
//

import UIKit

enum SSPullToRefreshViewState: Int {
    case normal
    case ready
    case loading
    case closing
}

enum SSPullToRefreshViewStyle: Int {
    case scrolling
    case `static`
}

class SSPullToRefreshView: UIView {
    var contentView = SSPullToRefreshSimpleContentView(frame: .zero)

    var defaultContentInset: UIEdgeInsets = .zero {
        didSet {
            _setContentInsetTop(topInset)
        }
    }

    var expandedHeight = 0.0
    var style: SSPullToRefreshViewStyle = .scrolling
    var delegate: SSPullToRefreshViewDelegate?

    private(set) var expanded = false {
        didSet {
            _setContentInsetTop(expanded ? expandedHeight : 0.0)
        }
    }

    private var scrollView: UIScrollView!

    private(set) var state: SSPullToRefreshViewState = .normal {
        didSet {
            let wasLoading = oldValue == .loading
            contentView.setState(state, withPullToRefreshView: self)

            if wasLoading && state != .loading {
                delegate?.pullToRefreshViewDidFinishLoading(self)
            } else if !wasLoading && state == .loading {
                _setPullProgress(1.0)
                delegate?.pullToRefreshViewDidStartLoading(self)
            }
        }
    }

    private var animationSemaphore: DispatchSemaphore!
    private var topInset: CGFloat = 0.0
    private var observation: NSKeyValueObservation?

    init(
        scrollView: UIScrollView,
        delegate: SSPullToRefreshViewDelegate
    ) {
        super.init(
            frame: CGRect(
                x: 0.0,
                y: 0.0 - scrollView.bounds.size.height,
                width: scrollView.bounds.size.width,
                height: scrollView.bounds.size.height
            )
        )

        for view in scrollView.subviews {
            if view is SSPullToRefreshView {
                NSException(name: NSExceptionName(rawValue: "SSPullToRefreshViewAlreadyAdded"), reason: "There is already a SSPullToRefreshView added to this scroll view. Unexpected things will happen. Don't do this.", userInfo: nil).raise()
            }
        }

        autoresizingMask = .flexibleWidth
        setupScrollView(scrollView)
        self.scrollView = scrollView
        self.delegate = delegate
        state = .normal
        expandedHeight = 70.0
        defaultContentInset = scrollView.contentInset

        self.scrollView.addSubview(self)

        contentView.setState(state, withPullToRefreshView: self)
        refreshLastUpdatedAt()
        addSubview(contentView)

        animationSemaphore = DispatchSemaphore(value: 0)
        animationSemaphore.signal()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        scrollView = nil
        delegate = nil
    }
}

// MARK: - Overrides

extension SSPullToRefreshView {
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard
            let sview = object as? UIScrollView,
            sview == scrollView,
            keyPath == "contentOffset",
            let change,
            let newValue = change[.newKey] as? CGPoint
        else { return }

        if style == .static {
            setNeedsLayout()
        }

        let y = newValue.y + defaultContentInset.top

        if scrollView.isDragging {
            if state == .ready {
                _setPullProgress(-y / expandedHeight)
                if y > -expandedHeight && y < 0.0 {
                    state = .normal
                }
            } else if state == .normal {
                _setPullProgress(-y / expandedHeight)
                if y < -expandedHeight {
                    state = .ready
                }
            } else if state == .loading {
                let insetAdjustment = y < 0 ? max(0, expandedHeight + y) : expandedHeight
                _setContentInsetTop(expandedHeight - insetAdjustment)
            }
            return
        } else if scrollView.isDecelerating {
            _setPullProgress(-y / expandedHeight)
        }

        guard state == .ready else { return }

        var newState: SSPullToRefreshViewState = .loading
        var expand = true
        if let shouldStartLoading = delegate?.pullToRefreshViewShouldStartLoading(self) {
            if !shouldStartLoading {
                newState = .normal
                expand = false
            }
        }
        _setState(newState, animated: true, expanded: expand, completion: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var size = bounds.size
        let contentSize = contentView.sizeThatFits(size)

        if contentSize.width < size.width {
            size.width = contentSize.width
        }

        if contentSize.height < expandedHeight {
            size.height = expandedHeight
        }

        var contentFrame = CGRect.zero
        contentFrame.origin.x = round((size.width - contentSize.width) / 2.0)
        contentFrame.size = contentSize

        switch style {
        case .scrolling:
            contentFrame.origin.y = size.height - contentSize.height
        case .static:
            contentFrame.origin.y = size.height + defaultContentInset.top + scrollView.contentOffset.y
        }

        contentView.frame = contentFrame
    }

    override func removeFromSuperview() {
        scrollView = nil
        super.removeFromSuperview()
    }
}

// MARK: - Setup

private extension SSPullToRefreshView {
    func setupScrollView(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.scrollView.addObserver(
            self,
            forKeyPath: "contentOffset",
            options: .new,
            context: nil
        )

        defaultContentInset = self.scrollView.contentInset
        _setContentInsetTop(topInset)
    }
}

// MARK: - Methods

extension SSPullToRefreshView {
    func startLoading() {
        startLoadingAndExpand(false, animated: false)
    }

    func startLoadingAndExpand(_ shouldExpand: Bool, animated: Bool) {
        startLoadingAndExpand(shouldExpand, animated: animated, completion: nil)
    }

    func startLoadingAndExpand(_ shouldExpand: Bool, animated: Bool, completion: (() -> Void)?) {
        guard state != .loading else { return }
        _setState(.loading, animated: animated, expanded: shouldExpand, completion: completion)
    }

    func finishLoading() {
        finishLoadingAnimated(true, completion: nil)
    }

    func finishLoadingAnimated(_ animated: Bool, completion: (() -> Void)?) {
        guard state == .loading else { return }
        _setState(.closing, animated: animated, expanded: false) {
            self.state = .normal
            completion?()
        }
        refreshLastUpdatedAt()
    }

    func refreshLastUpdatedAt() {
        let date = delegate?.pullToRefreshViewLastUpdatedAt(self) ?? Date()
        contentView.setLastUpdatedAt(date, withPullToRefreshView: self)
    }
}

// MARK: - Helpers

private extension SSPullToRefreshView {
//    func setState(_ state: SSPullToRefreshViewState) {
//        let wasLoading = self.state == .loading
//        self.state = state
//        contentView.setState(state, withPullToRefreshView: self)
//
//        if wasLoading && state != .loading {
//            delegate?.pullToRefreshViewDidFinishLoading(self)
//        } else if !wasLoading && state == .loading {
//            _setPullProgress(1.0)
//            delegate?.pullToRefreshViewDidStartLoading(self)
//        }
//    }

    func setExpanded(_ expanded: Bool) {
        self.expanded = expanded
        _setContentInsetTop(expanded ? expandedHeight : 0.0)
    }

    func _setContentInsetTop(_ topInset: CGFloat) {
        self.topInset = topInset
        var inset = defaultContentInset
        inset.top += topInset

        guard scrollView.contentInset != inset else { return }

        scrollView.contentInset = inset

        if style == .static {
            setNeedsLayout()
            layoutIfNeeded()
        }

        if scrollView.contentOffset.y <= 0.0 {
            scrollView.scrollRectToVisible(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0), animated: false)
        }

        delegate?.pullToRefreshView(self, didUpdateContentInset: scrollView.contentInset)
    }

    func _setState(_ state: SSPullToRefreshViewState, animated: Bool, expanded: Bool, completion: (() -> Void)?) {
        let fromState = self.state

        delegate?.pullToRefreshView(self, willTransitionToState: state, fromState: fromState, animated: animated)

        guard !animated else {
            DispatchQueue.global(qos: .background).async {
                self.animationSemaphore.wait()
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction, animations: {
                        self.state = state
                        self.expanded = expanded
                    }) { _ in
                        self.animationSemaphore.signal()
                        completion?()
                        self.delegate?.pullToRefreshView(self, didTransitionToState: state, fromState: fromState, animated: animated)
                    }
                }
            }
            return
        }

        self.state = state
        self.expanded = expanded
        completion?()
        delegate?.pullToRefreshView(self, didTransitionToState: state, fromState: fromState, animated: animated)
    }

    func _setPullProgress(_ pullProgress: CGFloat) {
//        guard 
//            self.contentView.responds(to: #selector(pullProgress))
//        else {
//            return
//        }


//        let newPullProgress = fmax(0.0, pullProgress)
//        contentView.setPullProgress(newPullProgress)
    }
}

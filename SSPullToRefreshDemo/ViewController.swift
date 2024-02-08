//
//  ViewController.swift
//  SSPullToRefreshDemo
//
//  Created by Adonis Dumadapat on 1/30/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private(set) var tableView: UITableView!

    private var pullToRefreshView: SSPullToRefreshView?
//    private var pullToRefreshView2: SSPullToRefresh2?

    private let words = [
        "Apple",
        "Banana",
        "Orange",
        "Grapes",
        "Pineapple",
        "Strawberry",
        "Watermelon"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        pullToRefreshView = SSPullToRefreshView(
            scrollView: tableView,
            delegate: self
        )

//        pullToRefreshView?.contentView = SSPullToRefreshSimpleContentView(frame: .zero)
//        pullToRefreshView2 = SSPullToRefresh2(scrollView: tableView)
    }
}

// MARK: - Helpers

private extension ViewController {
    func refresh() {
        guard let pullToRefreshView else { return }
        pullToRefreshView.startLoading()

        let seconds = 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.pullToRefreshView?.finishLoading()
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        10
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let randomIndex = Int(arc4random_uniform(UInt32(words.count)))
        cell.textLabel?.text = words[randomIndex]
        return cell
    }
}

// MARK: - SSPullToRefreshViewDelegate

extension ViewController: SSPullToRefreshViewDelegate {
    func pullToRefreshViewDidStartLoading(
        _ view: SSPullToRefreshView
    ) {
        refresh()
    }
}

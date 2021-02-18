//
//  SelectVersionTableViewController.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/24/21.
//

/*
Abstract:
A simple tableview that used to show different types of Tweets fetching implementation
*/

import UIKit
import AOperation

@available(iOS 14.0, *)
class SelectVersionTableViewController: UITableViewController {
	
	enum Version: Int, CaseIterable {
		case operation, operationWithCombine
		
		var title: String {
			switch self {
			case .operation:
				return "Operation"
			case .operationWithCombine:
				return "Operation with Combine"
			}
		}

	}
	
	init() {
		super.init(style: .plain)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.backBarButtonItem = .init(title: "Back", style: .plain, target: nil, action: nil)

		title = "Select a Version"
		tableView.tableFooterView = UIView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return Version.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
		let item = Version.allCases[indexPath.row]
		cell.textLabel?.text = item.title
		cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = Version.allCases[indexPath.row]
		
		let vc: UIViewController
		
		switch item {
		case .operation:
			vc = TweetsCollectionViewController()

		case .operationWithCombine:
			vc = TweetsModernCollectionViewController()
		}
		
		self.show(vc, sender: nil)
	}
	
}

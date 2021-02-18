//
//  RegisterationViewController.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 2/7/21.
//

/*
Abstract:
In this file, the process of requesting users's twitter Api key and Api Secret key is implemented.
We used AOperation to get authorization key from twitter using the given Api key and Api Secret key.

*/



import UIKit
import AOperation


/// Methods that notify the regiteration did finished or canceled
protocol RegisterationViewControllerDelegate: class {
	func registerationViewControllerDidFinishRegisteration()
	func registerationViewControllerDidCancelRegisteration()
}

/// A viewController for requesting twitter Api key and Api Secret from user
class RegisterationViewController: UITableViewController {

	weak var delegate: RegisterationViewControllerDelegate?
	
	let queue = AOperationQueue()
	
	enum Registeration: Int, CaseIterable {
		case apiKey, apiSecretKey
		
		var placeholder: String {
			switch self {
			case .apiKey:
				return "Enter your twitter api key"
			case .apiSecretKey:
				return "Enter your twitter api secret key"
			}
		}
	}
	
	lazy var apiKeyCell: RegisterationCell = {
		let cell = Bundle.main.loadNibNamed(String(describing: RegisterationCell.self), owner: self, options: nil)!.first as! RegisterationCell
		cell.textField.placeholder = Registeration.apiKey.placeholder
		return cell
	}()
	
	lazy var apiSecretKeyCell: RegisterationCell! = {
		let cell = Bundle.main.loadNibNamed(String(describing: RegisterationCell.self), owner: self, options: nil)!.first as! RegisterationCell
		cell.textField.placeholder = Registeration.apiSecretKey.placeholder
		return cell
	}()

	
	init() {
		if #available(iOS 13.0, *) {
			super.init(style: .insetGrouped)
		} else {
			// Fallback on earlier versions
			super.init(style: .grouped)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var registerButton: UIBarButtonItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let presented = self.navigationController ?? self
		presented.presentationController?.delegate = self
		self.title = "Registeration"
		
		registerButton = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(registerActionHandler(_:)))
		self.navigationItem.rightBarButtonItem = registerButton
		
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelActionHandler(_:)))
		self.navigationItem.leftBarButtonItem = cancelButton
		
		tableView.rowHeight = 50
		
    }
	
	// When user tapped register button, we check apiKey and apiSecretKey fields to not be empty.
	// Then we use AOperation to get authorization key
	@objc func registerActionHandler(_ sender: UIBarButtonItem) {
		guard let key = apiKeyCell.textField.text, let secretKey = apiSecretKeyCell.textField.text, !key.isEmpty, !secretKey.isEmpty else {
			
			let alert = UIAlertController(title: "Enter Api keys", message: "Apikey and ApiSecretKey fields should not be empty", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}
		
		let credential = TwitterApi.Credentials(key: key, secretKey: secretKey)
		let indicatorView = UIActivityIndicatorView(style: .gray)
		indicatorView.startAnimating()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
		
		// Here we use RequestAuthorizationOperation to get authorization key from twitter server.
		RequestAuthorizationOperation(credential)
			.didFinish({ [weak self] (result) in
				guard let `self` = self else { return }
				self.navigationItem.rightBarButtonItem = self.registerButton
				
			// The result of RequestAuthorizationOperation doesn't give us authorization key directly, instead it announce that is authorization key is now available or not.
				switch result {
				case .success(let state):
					if state == .available {
				// If the result is succeed and state is available we call registerationDidFinish delegate method and dismiss viewController
						self.delegate?.registerationViewControllerDidFinishRegisteration()
						self.dismiss(animated: true, completion: nil)
						return
					}
				default:
					break
				}
				// Otherwise we show an alert about the authorization failed
				let alert = UIAlertController(title: "Authorization Failed", message: "Failed to get authorization from Twitter, Please check your apikeys and try again.", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)

			})
			.add(to: queue)
	}
	
	@objc func cancelActionHandler(_ sender: UIBarButtonItem) {
		// If user taps on cancel we call registerationDidCancel delegate method, and dismis viewController
		self.delegate?.registerationViewControllerDidCancelRegisteration()
		self.dismiss(animated: true, completion: nil)
	}

	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return Registeration.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.item {
		case Registeration.apiKey.rawValue:
			return apiKeyCell
		case Registeration.apiSecretKey.rawValue:
			return apiSecretKeyCell
		default:
			return UITableViewCell()
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		"Enter Twitter Api inormations"
	}
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		"These are informations you got from Twitter Developer pannel"
	}

}

extension RegisterationViewController: UIAdaptivePresentationControllerDelegate {
	
	func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
		delegate?.registerationViewControllerDidCancelRegisteration()
	}
	
}

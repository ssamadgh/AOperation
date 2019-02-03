//
//  LoginViewController.swift
//  iOS_Exapmle
//
//  Created by Seyed Samad Gholamzadeh on 1/30/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@objc protocol LoginViewControllerDelegate {
	func loginViewControllerDidLogin()
	func loginViewControllerDidCancel()

}

class LoginViewController: UIViewController {

	var delegate: LoginViewControllerDelegate?

	@IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
	@IBAction func loginAction(_ sender: UIButton) {
		self.delegate?.loginViewControllerDidLogin()
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func cancelAction(_ sender: UIButton) {
		self.delegate?.loginViewControllerDidCancel()
		self.dismiss(animated: true, completion: nil)
	}


}

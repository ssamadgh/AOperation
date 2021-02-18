/*
  MoreInforamationOperation.swift
  MyOperationPractice

  Created by Seyed Samad Gholamzadeh on 7/13/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     This file contains the code to present more information about an earthquake as a model sheet.
*/

import Foundation
import SafariServices
import AOperation

/// An `Operation` to display a `URL` in an app-modal `SFSafariViewController`.
class MoreInformationOperation: VoidOperation {
    //MARK: Properties
    
    let URL: Foundation.URL

    //MARK: Inirialization
    init(URL: Foundation.URL) {
        self.URL = URL
        super.init()
        
        conditions(MutuallyExclusive<UIViewController>())
    }
    
    //MARK: Overrides
    
    override func execute() {
        DispatchQueue.main.async {
            self.showSafariViewController()
        }
    }
    
    private func showSafariViewController() {
        if let context = UIApplication.shared.keyWindow?.rootViewController {
            let safari = SFSafariViewController(url: URL, entersReaderIfAvailable: false)
            safari.delegate = self
            context.present(safari, animated: true, completion: nil)
        }
        else {
            finish()
        }
    }
}

extension MoreInformationOperation: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.finish()
    }
}

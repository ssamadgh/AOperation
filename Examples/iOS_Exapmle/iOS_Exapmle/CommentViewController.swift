//
//  ViewController.swift
//  iOS_Exapmle
//
//  Created by Seyed Samad Gholamzadeh on 10/24/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import AOperation

class CommentViewController: UIViewController {

	@IBOutlet weak var commentLabel: UILabel!
	
	@IBOutlet weak var addCommentButton: UIButton!
	
	let presenter = Presenter()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		AOperatinLogger.printOperationsState = true
	}

	@IBAction func addCommentAction(_ sender: UIButton) {
		
		self.presenter.addComment { (error) in
			
			DispatchQueue.main.async {
				
				if error != nil {
					self.commentLabel.text = "Failed to send comment"
					self.commentLabel.textColor = .red
				}
				else {
					self.commentLabel.text = "Comment added to the post"
					self.commentLabel.textColor = .gray
				}

				let op = BlockAOperation(mainQueueBlock: {
					self.commentLabel.alpha = 1
				})
				op.addObserver(BlockObserver { _, error in
					UIView.animate(withDuration: 3, animations: {
					self.commentLabel.alpha = 0
					})
				})
				op.waitUntilFinished()
				self.presenter.addOperation(op)
			}
			
		}
	}
	
}



class Presenter {
	
	let queue = AOperationQueue()
	
	func addComment(completion: @escaping (Error?) -> Void) {
		let operation = CommentOperation()
		operation.addCondition(LoginCondition())
		operation.addCondition(MutuallyExclusive<Comment>())

		let observer = BlockObserver(startHandler: nil, cancelHandler: nil, produceHandler: nil) { (_, errors) in
				completion(errors.first)
			}
		operation.addObserver(observer)
		queue.addOperation(operation)
	}
	
	func addOperation(_ op: Operation) {
		self.queue.addOperation(op)
	}
	
}


class CommentOperation: AOperation {
	
	override func execute() {
		sendComment()
	}
	
	func sendComment() {
		//Some Send methods
		DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
			self.finishWithError(nil)
		}
	}

}


public enum Comment { }

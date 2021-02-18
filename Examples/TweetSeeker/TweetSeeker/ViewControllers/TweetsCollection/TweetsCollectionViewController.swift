//
//  TweetsCollectionViewController.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/24/21.
//

/*
Abstract:
In this file we used AOperation to fetch tweets
and a collection view implemented to show fetched tweets.
*/


import UIKit
import AOperation

private let reuseIdentifier = "Cell"

class TweetsCollectionViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {

	var tweets: [Tweet] = [] {
		didSet {
			let oldTweetsCount = oldValue.count
			let newTweetsCount = tweets.count
			self.collectionView.performBatchUpdates {
				let oldPaths = (0..<oldTweetsCount).map { IndexPath(item: $0, section: 0)}
				let newPaths = (0..<newTweetsCount).map { IndexPath(item: $0, section: 0)}

				self.collectionView.deleteItems(at: oldPaths)
				self.collectionView.insertItems(at: newPaths)

			} completion: { (finished) in
				//...
			}
		}
	}
	
	let queue = AOperationQueue()
		
	var fetchOperation: AOperation?

	var searchTextField: UITextField!

	init() {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 16
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		super.init(collectionViewLayout: layout)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupSearchTextField()
		setupCollectionView()
	}
	
	func setupSearchTextField() {
		let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
		textField.placeholder = "Type a twiter username"
		textField.autocapitalizationType = .none
		textField.autocorrectionType = .no
		textField.returnKeyType = .done
		textField.textAlignment = .center
		textField.delegate = self
		textField.addTarget(self, action: #selector(textFieldDidChangeHandler(_:)), for: .editingChanged)
		textField.addTarget(self, action: #selector(textFieldDidBeginEditingHandler(_:)), for: .editingDidBegin)
		textField.addTarget(self, action: #selector(textFieldDidEndEditingHandler(_:)), for: .editingDidEnd)

		searchTextField = textField
		
		navigationItem.titleView = textField
	}
	
	func setupCollectionView() {
		self.collectionView.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
		self.collectionView.dataSource = self
		self.collectionView.prefetchDataSource = self
		self.collectionView.delegate = self
		self.collectionView.contentInset.top = 16

		collectionView.reloadData()
		
		// Register cell classes
		self.collectionView!.register(UINib(nibName: String(describing: TweetCollectionCell.self), bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
	}
		
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
		return tweets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCollectionCell
    
        // Configure the cell
		let tweet = tweets[indexPath.row]
		let color = UIColor(tweet.user.profileLinkColor)

		cell.nameLabel?.text = tweet.user.name
		cell.screenNameLabel?.text = "@"+tweet.user.screenName
		cell.screenNameLabel?.textColor = color
		cell.descriptionLabel?.text = tweet.text
		cell.profileImageView.layer.borderColor = color?.cgColor
		cell.profileImageView.layer.borderWidth = 2
				
		updateTweetImage(for: cell, with: tweet, at: indexPath)
		updateProfileImage(for: cell, with: tweet, at: indexPath)
		
        return cell
    }
	
	/// A method used to load imag of given cell and tweet
	func updateTweetImage(for cell: TweetCollectionCell, with tweet: Tweet, at indexPath: IndexPath) {
		let mediaURL = tweet.photo?.small
		cell.mediaURL = mediaURL
		if let url = mediaURL {
			
			if let cached = ImageLoader.publicLoader.image(for: url) {
				// If there is a cached image, we give it to cell image
				cell.image = cached
			}
			else {
				// if the cache isn't available, we ask ImageLoader to load it
				ImageLoader.publicLoader.load(url, for: indexPath) { [weak self] (url, path, image) in
					guard let `self` = self else { return }
					// After the image is loaded we fetch the cell of indexpath if it is still visible and give loaded image to it
					if let cell = self.collectionView.cellForItem(at: path) as? TweetCollectionCell, cell.mediaURL == url {
						cell.image = image
						// This line is used to update layout of cell
						self.collectionView.reloadItems(at: [path])
					}
				}
			}
			
		}
	}
	
	/// A method used to load profile imag of given cell and tweet
	func updateProfileImage(for cell: TweetCollectionCell, with tweet: Tweet, at indexPath: IndexPath) {
		let profileURL = tweet.user.profileImageUrl
		cell.profileURL = profileURL
		if let url = profileURL {
			if let cached = ImageLoader.publicLoader.image(for: url) {
				// If there is a cached image, we give it to cell profileImage
				cell.profileImage = cached
			}
			else {
				// if the cache isn't available, we ask ImageLoader to load it
				ImageLoader.publicLoader.load(url, for: indexPath) { [weak self] (url, path, image) in
					guard let `self` = self else { return }
					// After the image is loaded we fetch the cell of indexpath if it is still visible and give loaded image to it
					if let cell = self.collectionView.cellForItem(at: path) as? TweetCollectionCell, cell.profileURL == url {
						cell.profileImage = image
					}
				}
			}

		}
	}


	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			let tweet = tweets[indexPath.row]
			if let url = tweet.photo?.small {
				ImageLoader.publicLoader.load(url, for: indexPath)
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			let tweet = tweets[indexPath.row]
			if let url = tweet.photo?.small {
				ImageLoader.publicLoader.cancelFetch(url)
			}
		}

	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		searchTextField.resignFirstResponder()
	}
	
	@objc func textFieldDidBeginEditingHandler(_ sender: UITextField) {
		sender.textColor = .black
	}

	
	@objc func textFieldDidEndEditingHandler(_ sender: UITextField) {
		sender.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
	}
	
	@objc func textFieldDidChangeHandler(_ sender: UITextField) {
		sender.textColor = .black		
		guard let username = sender.text, !username.isEmpty else { return }
		
		// We used AOperation to handle process of
		// fetching tweets
		
		// If there is an enqueued fetchOperation we cancel it
		// and creating a new fetch operation with the given new username
		fetchOperation?.cancel()
		
		// We set a delay before fetching tweets to make sure
		// the given username is the one user wants to fetch
		// tweets for.
		fetchOperation =
		DelayOperation<Void>(1)
			.deliver(to: MapOperationBlock<Void, String> { _, finish in
				finish(.success(username))
			})
			// Do not forget to use [weak self] if you referenced to self or any other reference type instance objects.
			.deliver(to: FetchUserTimeLineOperation()).didFinish { [weak self] (result) in
				guard let `self` = self else { return }
			switch result {
			case .success(let tweets):
				self.searchTextField.textColor = tweets.count > 0 ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : .black
				self.tweets = tweets

			case .failure:
				self.tweets = []
				self.searchTextField.textColor = .black
				return
			}
		}
		// Always call this method at the end of a chain to enqueue chain of operations
		.add(to: queue)

	}
	
}

extension TweetsCollectionViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}
	
}

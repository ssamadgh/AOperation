//
//  TweetsModernCollectionViewController.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 2/5/21.
//

/*
Abstract:
In this file a combination of AOperation and Combine used to fetch tweets
and a modern collection view implemented to show fetched tweets.
*/


import UIKit
import AOperation
import Combine

private let reuseIdentifier = "Cell"

@available(iOS 14.0, *)
class TweetsModernCollectionViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching {

	enum Section {
		case main
	}

	var dataSource: UICollectionViewDiffableDataSource<Section, Tweet>! = nil

	var tweets: [Tweet] = [] {
		didSet {
			// we cancel operation at the end of operation
			cancellable?.cancel()
			let isEmpty = tweets.isEmpty
			self.searchTextField.textColor = isEmpty ? .black : #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)

			var snapshot = NSDiffableDataSourceSnapshot<Section, Tweet>()
			snapshot.appendSections([.main])
			snapshot.appendItems(tweets)
			dataSource.apply(snapshot, animatingDifferences: true)
		}
	}
	
	let queue = AOperationQueue()
		
	var searchTextField: UITextField!

	@Published var searchedText: String?
	
	
	init() {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 16
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		super.init(collectionViewLayout: layout)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		setupSearchTextField()
		setupCollectionView()
		setupDataSource()
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
		self.collectionView.prefetchDataSource = self
		self.collectionView.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
		self.collectionView.contentInset.top = 16

		collectionView.reloadData()
	}
	
	func setupDataSource() {
		let cellRegisteration = UICollectionView.CellRegistration<TweetCollectionCell, Tweet>(cellNib: UINib(nibName: String(describing: TweetCollectionCell.self), bundle: nil)) { [weak self] (cell, indexPath, tweet) in
			guard let `self` = self else { return }
			let color = UIColor(tweet.user.profileLinkColor)

			cell.nameLabel?.text = tweet.user.name
			cell.screenNameLabel?.text = "@"+tweet.user.screenName
			cell.screenNameLabel?.textColor = color
			cell.descriptionLabel?.text = tweet.text
			cell.profileImageView.layer.borderColor = color?.cgColor
			cell.profileImageView.layer.borderWidth = 2
					
			self.updateProfileImage(for: cell, with: tweet, at: indexPath)
			self.updateTweetImage(for: cell, with: tweet, at: indexPath)
		}
		
		dataSource = UICollectionViewDiffableDataSource<Section, Tweet>(collectionView: collectionView) { (collectionView, indexPath, tweet) -> UICollectionViewCell? in
			// Return the cell.
			return collectionView.dequeueConfiguredReusableCell(using: cellRegisteration, for: indexPath, item: tweet)
		}
		
		
		// initial data
		var snapshot = NSDiffableDataSourceSnapshot<Section, Tweet>()
		snapshot.appendSections([.main])
		snapshot.appendItems([])
		dataSource.apply(snapshot, animatingDifferences: false)
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
					// After the image is loaded we reload snapshot of image indexpath to update image of cell usign dataSource
					var updatedSnapshot = self.dataSource.snapshot()
					if let datasourceIndex = updatedSnapshot.indexOfItem(tweet) {
						let item = self.tweets[datasourceIndex]
						updatedSnapshot.reloadItems([item])
						self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
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
					// After the image is loaded we reload snapshot of image indexpath to update image of cell usign dataSource
					var updatedSnapshot = self.dataSource.snapshot()
					if let datasourceIndex = updatedSnapshot.indexOfItem(tweet) {
						let item = self.tweets[datasourceIndex]
						updatedSnapshot.reloadItems([item])
						self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
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
		searchTextField?.resignFirstResponder()
	}
	
	@objc func textFieldDidBeginEditingHandler(_ sender: UITextField) {
		sender.textColor = .black
	}

	
	@objc func textFieldDidEndEditingHandler(_ sender: UITextField) {
		sender.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
	}
	
	@objc func textFieldDidChangeHandler(_ sender: UITextField) {
		sender.textColor = .black
		setupOperationPublisher()
		searchedText = sender.text
	}
	
	func setupOperationPublisher() {
		// Here we used a combination of two AOperation and Combine
		// frameworks to fetching tweets
		// Notice to shortness and readablity of this bunch of codes
		cancellable =
			$searchedText
			.delay(for: 1, scheduler: RunLoop.main)
			.compactMap({ (text) -> String? in
				return text?.replacingOccurrences(of: " ", with: "")
			})
			.filter({!$0.isEmpty})
			.removeDuplicates()
			.deliver(to: FetchUserTimeLineOperation(), on: queue)
			.catch({ _ in Just([])})
			.assign(to: \.tweets, on: self)
	}
	
}

@available(iOS 14.0, *)
extension TweetsModernCollectionViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}
	
}

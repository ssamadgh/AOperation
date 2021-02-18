//
//  TweetsCollectionCell.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/25/21.
//

import UIKit

class TweetCollectionCell: UICollectionViewCell {

	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var screenNameLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!

	var widthConstraint: NSLayoutConstraint?
	
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
		contentView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			contentView.leftAnchor.constraint(equalTo: leftAnchor),
			contentView.rightAnchor.constraint(equalTo: rightAnchor),
			contentView.topAnchor.constraint(equalTo: topAnchor),
			contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
			])

		self.layer.cornerRadius = 20
		if widthConstraint == nil {
			let screenWidth = UIScreen.main.bounds.width
			widthConstraint = containerView.widthAnchor.constraint(equalToConstant: screenWidth - 32)
			widthConstraint?.identifier = "cell width"
			widthConstraint?.isActive = true
		}
    }
	
	var mediaURL: URL? {
		didSet {
			imageView.isHidden = mediaURL == nil
		}
	}
	
	var profileURL: URL?
	
	var image: UIImage? {
		didSet {
			
			if imageView.image != image {
				// A transition animation to have a better user expriense of loading image
				UIView.transition(with: imageView, duration: 0.2, options: [.transitionCrossDissolve]) {
					self.imageView.image = self.image
				} completion: { (_) in
					//...
				}
			}
			
		}
	}

	var profileImage: UIImage? {
		didSet {
			
			if profileImageView.image != profileImage {
				// A transition animation to have a better user expriense of loading image
				UIView.transition(with: profileImageView, duration: 0.2, options: [.transitionCrossDissolve]) {
					self.profileImageView.image = self.profileImage
				} completion: { (_) in
					//...
				}
			}
			
		}
	}
	
}

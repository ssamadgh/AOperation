//
//  RegisterationCell.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 2/7/21.
//

import UIKit

class RegisterationCell: UITableViewCell {

	@IBOutlet weak var textField: UITextField!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		textField.autocapitalizationType = .none
		textField.autocorrectionType = .no
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A UITableViewCell to display the high-level information of an earthquake
 */

import UIKit

class EarthquakeTableViewCell: UITableViewCell {
    // MARK: Properties
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var magnitudeLabel: UILabel!
    @IBOutlet var magnitudeImage: UIImageView!
    
    // MARK: Configuration
    
    func configure(_ earthquake: Earthquake) {
        timestampLabel.text = Earthquake.timestampFormatter.string(from: earthquake.timestamp)
        
        magnitudeLabel.text = Earthquake.magnitudeFormatter.string(from: NSNumber(value: earthquake.magnitude))
        
        locationLabel.text = earthquake.name
        
        let imageName: String
        
        switch earthquake.magnitude {
        case 0..<2: imageName = ""
        case 2..<3: imageName = "2.0"
        case 3..<4: imageName = "3.0"
        case 4..<5: imageName = "4.0"
        default:    imageName = "5.0"
        }
        
        magnitudeImage.image = UIImage(named: imageName)
    }
    
}


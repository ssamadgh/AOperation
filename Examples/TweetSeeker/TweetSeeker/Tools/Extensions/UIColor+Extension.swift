//
//  UIColor+Extension.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 2/2/21.
//

import UIKit

extension UIColor {
	
	/**
	 Initializes and returns a color object using the specified opacity and RGB component values.
	 - Parameter R: Abbreviation of red, this parameter accebt value from 0 to 255.
	 - Parameter G: Abbreviation of green, this parameter accebt value from 0 to 255.
	 - Parameter B: Abbreviation of blue, this parameter accebt value from 0 to 255.
	 - Parameter alpha: The opacity value of the color object, specified as a value from 0.0 to 1.0.
	 */
	convenience public init (R: CGFloat, G: CGFloat, B: CGFloat, alpha: CGFloat = 1) {
		self.init(red: R/255, green: G/255, blue: B/255, alpha: alpha)
	}

	convenience public init? (_ hex:String) {
		var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		if ((cString.count) != 6) {
			return nil
		}
		
		var rgbValue:UInt32 = 0
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		let red = CGFloat((rgbValue & 0xFF0000) >> 16)
		let green = CGFloat((rgbValue & 0x00FF00) >> 8)
		let blue = CGFloat(rgbValue & 0x0000FF)
		
		self.init(R: red, G: green, B: blue)
	}
	
}

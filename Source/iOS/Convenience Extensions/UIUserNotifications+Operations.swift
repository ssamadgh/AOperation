/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A convenient extension to UIKit.UIUserNotificationSettings.
*/

#if os(iOS)

import UIKit
import UserNotifications

extension UIUserNotificationSettings {
    
    /// Check to see if one Settings object is a superset of another Settings object.
    func contains(_ settings: UIUserNotificationSettings) -> Bool {
        // our types must contain all of the other types
        if !types.contains(settings.types) {
            return false
        }
        
        let otherCategories = settings.categories ?? []
        let myCategories = categories ?? []
        
        return myCategories.isSuperset(of: otherCategories)
    }
    
    /**
        Merge two Settings objects together. `UIUserNotificationCategories` with
        the same identifier are considered equal.
    */
    func settingsByMerging(_ settings: UIUserNotificationSettings) -> UIUserNotificationSettings {
        let mergedTypes = types.union(settings.types)
        
        let myCategories = categories ?? []
        var existingCategoriesByIdentifier = Dictionary(sequence: myCategories) { $0.identifier }
        
        let newCategories = settings.categories ?? []
        let newCategoriesByIdentifier = Dictionary(sequence: newCategories) { $0.identifier }
        
        for (newIdentifier, newCategory) in newCategoriesByIdentifier {
            existingCategoriesByIdentifier[newIdentifier] = newCategory
        }
        
        let mergedCategories = Set(existingCategoriesByIdentifier.values)
        return UIUserNotificationSettings(types: mergedTypes, categories: mergedCategories)
    }
}

@available(iOS 10.0, *)
extension UNAuthorizationOptions {
	
	func merge(by options: UNAuthorizationOptions) -> UNAuthorizationOptions {
		return self.union(options)
	}
}

#endif

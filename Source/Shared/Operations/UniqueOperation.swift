//
//  UniqueOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 1/8/20.
//

import Foundation

/// A protocol that declares  an operation type that should be unique
///
/// By adopting this protocol to an operation type you prevent that type from duplicate executation in same time
public protocol UniqueOperation: AOperation {
	
	/// An id that used to prevent an operation from duplicate executation in same time
	var uniqueId: String { get }
}

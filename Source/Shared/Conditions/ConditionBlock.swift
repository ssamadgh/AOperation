//
//  ConditionBlock.swift
//  AOperation
//
//  Created by Seyed Samad Gholamzadeh on 11/25/20.
//

import Foundation


internal struct ConditionBlock: AOperationCondition {
	
	public var dependentOperation: AOperation? = nil
	
	public static var isMutuallyExclusive: Bool = false

	public var evaluateBlock: ((OperationConditionResult) -> Void) -> Void
	
	init(_ evaluateBlock: @escaping ((OperationConditionResult) -> Void) -> Void) {
		self.evaluateBlock = evaluateBlock
	}
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		evaluateBlock(completion)
	}
}

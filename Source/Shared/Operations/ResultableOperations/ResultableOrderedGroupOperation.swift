//
//  ResultableOrderedGroupOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 12/5/19.
//

import Foundation

open class ResultableOrderedGroupOperation<T>: OrderedGroupOperation {
    
    private var resultCompletion: ((Result<T, AOperationError>) -> Void)?
    
    public final func didFinishWithResult(_ completion: @escaping (Result<T, AOperationError>) -> Void) {
        self.resultCompletion = completion
    }
    
    public final func finish(with result: Result<T, AOperationError>) {
        self.resultCompletion?(result)
    }
    
    
    open override func finished(_ errors: [AOperationError]) {
        if let error = errors.first {
            let result: Result<T, AOperationError> = .failure(error)
            self.finish(with: result)
        }
    }
}

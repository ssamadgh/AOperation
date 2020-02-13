//
//  ResultAOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 12/5/19.
//

import Foundation

open class ResultableOperation<T>: AOperation {
    
    private var finishedResult: Result<T, AOperationError>?
    private var resultCompletion: ((Result<T, AOperationError>) -> Void)?
    
    public final func didFinishWithResult(_ completion: @escaping (Result<T, AOperationError>) -> Void) {
        self.resultCompletion = completion
    }
    
    public override func observeDidFinish(_ finishHandler: @escaping (([AOperationError]) -> Void)) {
        fatalError("Use `public final func didFinishWithResult(_ completion: @escaping (Result<T, AOperationError>) -> Void)` Instead")
    }
    
    private func privateFinish(with result: Result<T, AOperationError>) {
        self.resultCompletion?(result)
    }
    
    public final func finish(with result: Result<T, AOperationError>) {
        self.finishedResult = result
        
        var opError: AOperationError?
        switch result {
        case let .failure(error):
            opError = error
        default:
            break
        }
        
        self.finishWithError(opError)
    }
    
    
    open override func finished(_ errors: [AOperationError]) {
        if let error = errors.first {
            let result: Result<T, AOperationError> = .failure(error)
            self.privateFinish(with: result)
        }
        else {
            
            if let result = self.finishedResult {
                self.privateFinish(with: result)
            }
        }
    }
    
}

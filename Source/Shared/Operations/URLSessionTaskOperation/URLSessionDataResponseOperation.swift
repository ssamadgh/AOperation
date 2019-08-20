//
//  URLSessionDataResponseOperation.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 8/20/19.
//

import Foundation


protocol URLSessionDataResponseOperation {
    
    init(data: Data?, response: URLResponse?, error: Error?)
}


typealias DataResponseOperation = URLSessionDataResponseOperation & Operation


func getOperation(_ operation: DataResponseOperation) {
    
}

class TestResponseOperation: DataResponseOperation {
    
    
    required init(data: Data?, response: URLResponse?, error: Error?) {
        
    }
    
    init(data: Data?, response: URLResponse?, error: Error?, completion: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        completion(data, response, error)
    }
}

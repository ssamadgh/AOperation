//
//  JSONDecoderOperation.swift
//  TweetSeeker
//
//  Created by Seyed Samad Gholamzadeh on 1/22/21.
//

import Foundation
import AOperation

/// An operation used to decode received data to the given type model
public class JSONDecoderOperation<Output: Decodable>: ResultableOperation<Output>, ReceiverOperation {
	
	public var receivedValue: Result<Data, AOperationError>?

	
	public override func execute() {
		guard let value = receivedValue else {
			finish(with: .failure(.receivedValueIsNil(in: self)))
			return
		}
		
		switch value {
		case .success(let data):
			
			do {
				let decoded = try JSONDecoder().decode(Output.self, from: data)

				self.finish(with: .success(decoded))
			} catch {
				finish(with: .failure(AOperationError(error)))
			}

			
		case .failure(let error):
			finish(with: .failure(error))
		}
	}
	
}

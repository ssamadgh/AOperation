//
//  extension+Publishers.swift
//  AOperation iOS
//
//  Created by Seyed Samad Gholamzadeh on 12/4/20.
//

#if canImport(Combine)
import Foundation
import Combine

public protocol BaseOperationSubscription {
	
	func updateOperation(with newOperation: AOperation)
}

//MARK: - OperationMiddlePublisher

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
extension Publishers {
	
	
	/// Receives all elements from an upstream publisher, executes given operation with the received elements and publishes result of operation to received subscriber.
	public struct OperationMiddlePublisher<Upstream: Publisher, Operation: ResultableOperation<Output> & ReceiverOperation, Output>: Publisher
	where Operation.Input == Upstream.Output {

		public typealias Failure = AOperationError
	
		public let upstream: Upstream
		unowned let queue: AOperationQueue
		let operation: Operation

		/// Initializes an instance of OperationMiddlePublisher that used in Combine APIs
		/// - Parameters: The upstream publisher
		///   - upstream: An AOperationQueue that  given operation added to
		///   - operation: A ResultableOperation that OperationPublisher observes it and publishes its result
		///   - queue: An AOperationQueue that  given operation added to
		init(upstream: Upstream, operation: Operation, queue: AOperationQueue) {
			self.upstream = upstream
			self.queue = queue
			self.operation = operation
		}
		
		public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
			// A subscriber with the given subscriber and current publisher
			// is created and added as subscriber to the upstream to receive it.
			let s = Inner(pub: self, sub: subscriber)
			self.upstream
				.mapError {
					if let opError = ($0 as? AOperationError) { return opError } else { return AOperationError($0) }
				}
				.receive(subscriber: s)
		}
	
	
	}

}

//MARK: - Inner subcriber of OperationMiddlePublisher

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
extension Publishers.OperationMiddlePublisher {
	
	/// A subscriber used in OperationMiddlePublisher to be given as subscriber to upstream publisher
	private final class Inner<S>: Subscription,
		Subscriber,
		CustomStringConvertible,
		CustomDebugStringConvertible
	where
		S: Subscriber,
		S.Input == Output,
		S.Failure == Failure {
		
		
		typealias Failure = AOperationError
		typealias Input = Upstream.Output
		typealias Pub = Publishers.OperationMiddlePublisher<Upstream, Operation, Output>
		typealias Sub = S
		
		let lock = Lock()
		
		let anchorQueue = AOperationQueue()

		let queue: AOperationQueue
		var operation: Operation?
		private let initialClone: (ResultableOperation<Output> & RetryableOperation)?

		let sub: Sub
		
		var state: RelayState = .waiting
		var demand: Subscribers.Demand = .none
		
		/// Initializes a subscriber for OperationMiddlePublisher
		/// - Parameters:
		///   - pub: current publisher which used to access to its operation and queue
		///   - sub: The subscriber which published elements should be delivered to
		init(pub: Pub, sub: Sub) {
			self.queue = pub.queue
			self.operation = pub.operation
			self.initialClone = (operation as? ResultableOperation<Output> & RetryableOperation)?.clone()
			self.sub = sub
						
		}
		
		func request(_ demand: Subscribers.Demand) {
			self.lock.lock()
			guard let subscription = self.state.subscription else {
				self.lock.unlock()
				return
			}
			
			// Adding given demand to old demands
			let old = self.demand
			self.demand += demand
			// calculating new demands should be requested
			let new = calculateDemand(with: self.demand)
			
			self.lock.unlock()
			
			if old == 0 {
				// Requesting new elements do to the new demand.
				subscription.request(new)
			}
		}
		
		func receive(subscription: Subscription) {
			self.lock.lock()
			switch self.state {
			case .waiting:
				self.state = .relaying(subscription)
				self.lock.unlock()
				self.sub.receive(subscription: self)
			case .relaying:

				self.lock.unlock()
				subscription.cancel()
				self.state = .relaying(subscription)
				let demand = calculateDemand(with: self.demand)
				self.lock.unlock()
				
				subscription.request(demand)

			case .completed:
				self.lock.unlock()
				subscription.cancel()
			}
		}
		
		func receive(_ input: Upstream.Output) -> Subscribers.Demand {
			self.lock.lock()
			guard self.state.isRelaying else {
				self.lock.unlock()
				return .none
			}
			
			self.lock.unlock()

			
			//If the publisher produced an element we deliver it to the given operation
			let result = Result<Input, Failure>.success(input)
			guard let operation = initializeNewOperation() else { return .none }
			operation.receivedValue = result
			// If operation is in initialized state we add it to queue.
			if operation.isInitialized {

				observeOperation(operation)
				
				operation.add(to: queue)
			}

			// we make the given anchorQueue active to release dependency of given operation and execute it
			self.anchorQueue.isSuspended = false

			// In either case of given operation conformed CloneableOperation or not
			// we do not need to change number of requested demands of received elements
			return .none
		}

		private var shouldComplete = false
		
		func receive(completion: Subscribers.Completion<AOperationError>) {
			guard let subscription = self.lock.withLockGet(self.state.complete()) else {
				return
			}

			switch completion {
			case .finished:
				// If we received a completion we set shouldComplete to true
				// to send a completion to subscriber.
				subscription.cancel()
				self.lock.withLock {
					self.shouldComplete = true
				}
				
			break
			case .failure(let error):
				
				//If the publisher produced an error we deliver it to the given operation
				let result = Result<Input, Failure>.failure(error)
				guard let operation = initializeNewOperation() else {
					subscription.cancel()
					self.sub.receive(completion: completion)
					return
				}
				operation.receivedValue = result
				if operation.isInitialized {
					observeOperation(operation)
					operation.add(to: queue)
				}

				// we make the given anchorQueue active to release dependency of given operation and execute it
				self.anchorQueue.isSuspended = false

				
				
			}
		}

		func cancel() {
			// Should cancel subscription
			self.lock.withLockGet(self.state.complete())?.cancel()
			// Should cancel any operation with the `Operation` type
			self.queue.operations.forEach { (operation) in
				if let op = operation as? Operation, !op.isFinished {
					operation.cancel()
				}
			}
		}
		
		deinit {
			// We check to be sure any operation with the `Operation` type
			// will be cancel
			self.queue.operations.forEach { (operation) in
				if let op = operation as? Operation, !op.isFinished {
					operation.cancel()
				}
			}
			
		}
		
		
		/// returns given operation if is in initialized state or makes a clone from given operation and returns it.
		/// - Returns: An Operation in Initialized state
		func initializeNewOperation() -> Operation? {
			let operation: Operation?

			//returns given operation if isn't in isFinished state, otherwise makes a clone from the given operation and returns it.
			if !(self.operation?.isFinished ?? true) {
				operation = self.operation
			}
			else {

				guard let clone = initialClone?.clone() else {
					fatalError("The Operation \(self.operation?.name ?? "") is not CloneableOperation, Please adopt Cloneable to operation.")
				}

				operation = clone as? Operation
			}

			guard operation != nil else { return nil }
			
			if (operation!.isInitialized) && !anchorQueue.operations.contains(operation!) {
				anchorQueue.isSuspended = true
				let anchorOperation = AOperationBlock(mainQueueBlock: {})
				operation!.addDependency(anchorOperation)
				anchorQueue.addOperation(anchorOperation)
			}

			return operation

		}
		
		/// a method to add observer to operatoin, to send its result to a given operation.
		/// - Parameter operation: The operation should be execute
		func observeOperation(_ operation: Operation) {
			// We used didFinish method to observer operation finish state
			operation.didFinish { [weak self] (result)  in
				guard let `self` = self else { return }
				switch result {
				case .success( let output):
					// We check to send elements to subscriber if and only if it is allowed by checking that demand is more than zero.
					self.lock.lock()
					let demand = self.demand
					self.lock.unlock()
					
					if demand > 0 {
						// We reduce current demand after sending result and adding the received demand to current demand to check if subscriber still needs receiving elements
						let demand = self.sub.receive(output)
						self.lock.withLock {
							self.demand -= 1
							self.demand += demand
						}
					}
					
					// Checking a should complete boolean to check that if
					// completion should send to subscriber
					let shouldComplete = self.lock.withLockGet(self.shouldComplete)
					if shouldComplete {
						self.sub.receive(completion: .finished)
					}
					
				case .failure(let error):
					// We call completion on subscriber if result is failure.
					// Becaues calling completion closes combine pupline.
					self.sub.receive(completion: .failure(error))
				}
				
			}
		}
		
		/// Calculates demad should be requested for elements by the given demand
		/// - Parameter demand: The given demend
		/// - Returns: A new demand that used to request element
		func calculateDemand(with demand: Subscribers.Demand) -> Subscribers.Demand {
			// If operation is RetryableOperation, so we can clone it
			// and execute its tasks again, so we accept given demand
			if self.operation is RetryableOperation {
				return demand
			}
			else {
				//but if the given operation isn't RetryableOperation,
				// and we couldn't clone it we just accept one demand
				// or none if our operation added to queue to execute now.
				return (self.operation?.isInitialized ?? false) ? .max(1) : .none
			}
		}
		
		var description: String {
			"OperationPublisher.Inner"
		}
		
		var debugDescription: String {
			"OperationPublisher.Inner"
		}
		
	}
	

}




@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
extension Publishers {

	
	//MARK: - OperationPublisher
	/// A publisher delivers given operation result to one or more Subscriber instances.
	public struct OperationPublisher<Output>: Publisher {
				
		var combineIdentifier: CombineIdentifier = CombineIdentifier()
		
		public typealias Failure = AOperationError
		
		unowned let queue: AOperationQueue
		let operation: ResultableOperation<Output>
		private let initialClone: (ResultableOperation<Output> & RetryableOperation)?
				
		/// Initializes an instance of OperationPublisher that used in Combine APIs
		/// - Parameters:
		///   - queue: An AOperationQueue that  given operation added to
		///   - operation: A ResultableOperation that OperationPublisher observes it and publishes its result
		init(operation: ResultableOperation<Output>, queue: AOperationQueue) {
			self.queue = queue
			self.operation = operation
			self.initialClone = (operation as? ResultableOperation<Output> & RetryableOperation)?.clone()
		}

		
		public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
			let operation: ResultableOperation<Output>
			
			//These bunch of codes handles retry for publishers
			
			//We check is this the first time the publisher receives subscriber or not
			//because at the first time, the given operation is in initialized state and could be added to queue
			//but once the operation added to queue it cannot be reused (for the time a rety publisher wants to repeat the flow) so we should clone the used operation to a new operaion in isInitialized state
			if self.operation.isInitialized {
				operation = self.operation
			}
			else {
				guard let clone = initialClone?.clone() else {
					fatalError("The Operation is not RetryableOperation, Please adopt Cloneable to operation.")
				}
				
				operation = clone
			}
			
			// As a subscriber received we create an instance of OperationSubscription and attaching it to the given subscriber then we add operation to given queue.
			let subscription = OperationSubscription(target: subscriber)
			subscription.updateOperation(with: operation)
			subscriber.receive(subscription: subscription)
			operation.add(to: queue)
		}

	}
	
	//MARK: - OperationSubscription
	
	/// A class that representing the connection of a subscriber to a OperationPublisher.
	///
	/// This class used by OperationPublisher and react to subscriber  attached to OperationPublisher.
	
	public class OperationSubscription<Output, S: Subscriber>: BaseOperationSubscription, Subscription where S.Input == Output, S.Failure == AOperationError {
		
		// Initial value of target demand is none, means target dosn't need receive elements
		var demand: Subscribers.Demand = .none
		
		var operation: ResultableOperation<Output>? {
			didSet {
				// We used didFinish method to observer operation finish state
				self.operation?.didFinish { [weak self] (result)  in
					guard let `self` = self else { return }
					switch result {
					case .success( let output):
						// We check to send result only if target needs receiving element by checking target demand being more than zero.
						if let target = self.target, self.demand > 0 {
							let demand = target.receive(output)
							// We reduce current demand after sending result and adding the received demand to current demand to check if target still needs receiving elements
							self.demand -= 1
							self.demand += demand
						}
						
					case .failure(let error):
						// We call completion on target only if result is failure.
						// Becaues calling completion closes combine pupline.
						if let target = self.target {
							target.receive(completion: .failure(error))
						}
						
					}

				}
			}
		}
		
		var target: S?
		
		/// Initializes an instance of OperationSubscription used by OperationPublisher to attach OperationSubscription to the given subscriber
		///
		/// OperationSubscription observes the given operation to send its result to the attached subscriber as operation finished
		/// - Parameters:
		///   - operation: The given ResultableOperation to observe
		///   - target: The attached subscriber that receives result of observed operation
		init(target: S) {
			self.target = target
		}
		
		public func updateOperation(with newOperation: AOperation) {
			self.operation?.cancel()
			self.operation = nil
			self.operation = newOperation as? ResultableOperation<Output>
		}
		
		public func request(_ demand: Subscribers.Demand) {
			// Updating demand with target initial announce of requested demand.
			//By the number of demand, target announces that number of times needs receive element.
			self.demand += demand
		}
		
		public func cancel() {
			// As the cancel method get called we release subsciber and cancelling observed operation
			operation?.willFinishCompletion = nil
			operation?.cancel()
			target = nil
		}
		
	}
	
	
}

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
public extension ResultableOperation {
	/// Returns a publisher that wraps a ResultableOperation added to given OperationQueue.
	///
	/// The publisher publishes result when the Operation finishes, or be canceled.
	/// - Parameter queue: An OperationQueue that wrapped operation added to
	func publisher(on queue: AOperationQueue) -> Publishers.OperationPublisher<Output> {
		Publishers.OperationPublisher(operation: self, queue: queue)
	}
}

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
public extension Publisher {
	
	/// Tells the publisher that it had to deliver its result to the given subscriber operation.
	/// - Parameters:
	///   - operation: A ResultableOperation that conformed SubscriberOperation protocol
	///   - queue: An OperationQueue that given operation  add to
	/// - Returns: An OperationPublisher
	func deliver<Output, Operation: ReceiverOperation & ResultableOperation<Output>>(to operation: Operation, on queue: AOperationQueue) -> Publishers.OperationMiddlePublisher<Self, Operation, Output> where Operation.Input == Self.Output {
		let publisher = Publishers.OperationMiddlePublisher(upstream: self, operation: operation, queue: queue)
		return publisher
	}
	
}

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
public extension Publishers.OperationPublisher {
	
	/// Tells the OperationPublisher that it had to deliver its result to the given subscriber operation.
	/// - Parameter operation: A ResultableOperation that conformed SubscriberOperation protocol
	/// - Returns: An OperationPublisher
	func deliver<Output, Operation: ReceiverOperation & ResultableOperation<Output>>(to operation: Operation) -> Publishers.OperationMiddlePublisher<Self, Operation, Output> where Operation.Input == Self.Output {
		deliver(to: operation, on: queue)
	}
	
}

@available(watchOSApplicationExtension 6.0, *)
@available(tvOS 13.0, *)
@available(OSX 10.15, *)
@available(iOS 13.0, *)
public extension Publishers.OperationMiddlePublisher {
	
	/// Tells the OperationSubscriber that it had to deliver its result to the given subscriber operation.
	/// - Parameter operation: A ResultableOperation that conformed SubscriberOperation protocol
	/// - Returns: An OperationPublisher
	func deliver<ResultOutput, GivenOperation: ReceiverOperation & ResultableOperation<ResultOutput>>(to operation: GivenOperation) -> Publishers.OperationMiddlePublisher<Self, GivenOperation, ResultOutput> where GivenOperation.Input == Self.Output {
		let publisher = Publishers.OperationMiddlePublisher<Self, GivenOperation, ResultOutput>(upstream: self, operation: operation, queue: queue)
		return publisher
	}
	
}



#endif

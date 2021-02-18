/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the foundational subclass of NSOperation.
*/

import Foundation



@objc private extension AOperation {
	/**
	Add the "state" key to the key value observable properties of `Foundation.Operation`.
	*/
	class func keyPathsForValuesAffectingIsReady() -> Set<String> {
		return ["state", "cancelledState"]
	}
	
	class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
		return ["state"]
	}
	
	class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
		return ["state"]
	}
	
	class func keyPathsForValuesAffectingIsCancelled() -> Set<String> {
		return ["cancelledState"]
	}
	
}

/**
A subclass of `NSOperation` from which all other operations should be derived.
This class adds both Conditions and Observers, which allow the operation to define
extended readiness requirements, as well as notify many interested parties
about interesting operation state changes
*/
open class AOperation: Foundation.Operation {
	
	/// UUID of a publisher operation when a subscriber operation subscribed to it
	internal var publisherId: UUID?

	/// UUID of a subscriber operation when subscibed to a publisher operation
	internal var subscriberId: UUID?
	
    public static var key: String {
        return "\(String(describing: self))"
    }
    
    public override init() {
        super.init()
        self.name = "\(type(of: self))"
    }
    
	/* The completionBlock property has unexpected behaviors such as executing twice and executing on unexpected threads. BlockObserver executes in an expected manner.
	*/
//	@available(*, deprecated, message: "use BlockObserver completions instead")
//	override open var completionBlock: (() -> Void)? {
//		set {
//			fatalError("The completionBlock property on NSOperation has unexpected behavior and is not supported in AOperation 😈")
//		}
//		get {
//			return nil
//		}
//	}
	
	public weak var delegate: AOperationDelegate?
	
	// MARK: State Management
	
	fileprivate enum State: Int, Comparable {
		/// The initial state of an `AOperation`.
		case initialized
		
		/// The `AOperation` is ready to begin evaluating conditions.
		case pending
		
		/// The `AOperation` is evaluating conditions.
		case evaluatingConditions
		
		/**
		The `AOperation`'s conditions have all been satisfied, and it is ready
		to execute.
		*/
		case ready
		
		/// The `AOperation` is executing.
		case executing
		
		/**
		Execution of the `AOperation` has finished, but it has not yet notified
		the queue of this.
		*/
		case finishing
		
		/// The `AOperation` has finished executing.
		case finished
		
		func canTransitionToState(_ target: State, operationIsCancelled cancelled: Bool) -> Bool {
			switch (self, target) {
			case (.initialized, .pending):
				return true
			case (.pending, .evaluatingConditions):
				return true
			case (.pending, .finishing) where cancelled:
				return true
			case (.pending, .ready) where cancelled:
				return true
			case (.evaluatingConditions, .ready):
				return true
			case (.ready, .executing):
				return true
			case (.ready, .finishing):
				return true
			case (.executing, .finishing):
				return true
			case (.finishing, .finished):
				return true
				
			default:
				return false
			}
		}
	}
	
    
    /// Prevents any operation with same type to added to queue while this operation is in.
    /// - Note: Changing this property after adding operation to queue produces undefined behavior and so results a fatalError.
//    public var isUnique: Bool = false {
//        didSet {
//            if state > .initialized {
//                fatalError("Changing `isUnique` property of an operation after adding it to the queue produces undefined behavior")
//            }
//        }
//    }
	
	/**
	Indicates that the AOperation can now begin to evaluate readiness conditions,
	if appropriate.
	*/
	internal func didEnqueue() {
		state = .pending
	}
	
	/// Private storage for the `state` property that will be KVO observed.
	fileprivate var _state = State.initialized
	
	/// A lock to guard reads and writes to the `_state` property
	fileprivate let stateLock = NSRecursiveLock()
	
	fileprivate var state: State {
		get {
			return stateLock.withCriticalScope {
				_state
			}
		}
		
		set(newState) {
			/*
			It's important to note that the KVO notifications are NOT called from inside
			the lock. If they were, the app would deadlock, because in the middle of
			calling the `didChangeValueForKey()` method, the observers try to access
			properties like "isReady" or "isFinished". Since those methods also
			acquire the lock, then we'd be stuck waiting on our own lock. It's the
			classic definition of deadlock.
			*/
			
			willChangeValue(forKey: "state")
			
			stateLock.withCriticalScope { () -> Void in
				guard _state != .finished else {
					return
				}
				
				assert(_state.canTransitionToState(newState, operationIsCancelled: isCancelled), "Performing invalid state transition.")
				_state = newState
			}
			
			didChangeValue(forKey: "state")
		}
	}
	
	public var isInitialized: Bool {
		state == .initialized
	}
	
	
	// Here is where we extend our definition of "readiness".
	override open var isReady: Bool {
		
		var _ready = false
		
		stateLock.withCriticalScope {
			switch state {
				
			case .initialized:
				// If the operation has been cancelled, "isReady" should return true
				_ready = isCancelled
				
			case .pending:
				// If the operation has been cancelled, "isReady" should return true
				guard !isCancelled else {
					state = .ready
					_ready = true
					return
				}
				
				// If super isReady, conditions can be evaluated
				if super.isReady {
					evaluateConditions()
					_ready = state == .ready
				}
				
			case .ready:
				_ready = super.isReady || isCancelled
				
			default:
				_ready = false
			}
			
		}
		
		return _ready
		
	}
	
	/**
	Used for performing work that has been explicitly requested by the user, and for which results must be immediately presented in order to allow for further user interaction. For example, loading an email after a user has selected it in a message list.
	*/
	public var userInitiated: Bool {
		get {
			return qualityOfService == .userInitiated
		}
		
		set {
			assert(state < .executing, "Cannot modify userInitiated after execution has begun.")
			
			qualityOfService = newValue ? .userInitiated : .default
		}
	}
	
	override open var isExecuting: Bool {
		return state == .executing
	}
	
	override open var isFinished: Bool {
		return state == .finished
	}
	
	var _cancelled = false {
		willSet {
			willChangeValue(forKey: "cancelledState")
		}
		
		didSet {
			didChangeValue(forKey: "cancelledState")
		}
	}
	
	override open var isCancelled: Bool {
		return _cancelled
	}
	
	fileprivate func evaluateConditions() {
		assert(state == .pending && !isCancelled, "evaluateConditions() was called out-of-order")
		
		state = .evaluatingConditions
		
		guard conditions.count > 0 else {
			state = .ready
			return
		}
		
		OperationConditionEvaluator.evaluate(conditions, operation: self) { failures in
			if !failures.isEmpty {
				self.internalErrors += failures
			}
			
			self.state = .ready
		}
		
	}
	
	// MARK: Observers and Conditions
	
	fileprivate(set) var conditions = [AOperationCondition]()
	
	public final func addCondition(_ condition: AOperationCondition) {
		assert(state < .evaluatingConditions, "Cannot modify conditions after execution has begun.")
		let currentConditionsKeys = self.conditions.map({type(of: $0).key})
		if !(currentConditionsKeys.contains(type(of: condition).key)) {
			self.conditions.append(condition)
		}
	}
	
	/// Adds conditions to the operatoin
	/// - Parameter conditions: conditoins should be add to operation
	@discardableResult
	public final func conditions(_ conditions: AOperationCondition...) -> Self {
		return self.conditions(conditions)
	}
	
	/// Adds conditions to the operatoin
	/// - Parameter conditions: conditoins should be add to operation
	@discardableResult
	public final func conditions(_ conditions: [AOperationCondition]) -> Self {
		assert(state < .evaluatingConditions, "Cannot modify conditions after execution has begun.")
		var newConditions: [AOperationCondition] = []
		let currentConditionsKeys = self.conditions.map({type(of: $0).key})
		for condition in conditions {
			if !(currentConditionsKeys.contains(type(of: condition).key)) {
				newConditions.append(condition)
			}
		}
		
		self.conditions.append(contentsOf: newConditions)
		return self
	}
	
	/// A closuer of conditon that should be checked before operation starts
	/// - Parameter block: A conditon block that should be called and checked before operation starts
	@discardableResult
	public final func condition(_ block: @escaping ((OperationConditionResult) -> Void) -> Void) -> Self {
		self.conditions.append(ConditionBlock(block))
		return self
	}
	
	fileprivate(set) var observers = [AOperationObserver]()
	
	/// Adds given observer to the operation
	/// - Parameter observer: Observer should be observe with operation
	public func addObserver(_ observer: AOperationObserver) {
		assert(state < .executing, "Cannot modify observers after execution has begun.")
		
		observers.append(observer)
	}
	
	/// Adds given observers to the operation
	/// - Parameter observers: Observers should be observe with operation
	@discardableResult
	public final func observers(_ observers: [AOperationObserver]) -> Self {
		assert(state < .executing, "Cannot modify observers after execution has begun.")

		self.observers.append(contentsOf: observers)
		return self
	}

	override open func addDependency(_ operation: Foundation.Operation) {
		assert(state < .executing, "Dependencies cannot be modified after execution has begun.")
		
		super.addDependency(operation)
	}
	
	/// Adds given operations as dependencies of operation
	/// - Parameter operations: Operations to add as dependencies to operation
	@discardableResult
	public final func dependencies(_ operations: [Foundation.Operation]) -> Self {
		assert(state < .executing, "Dependencies cannot be modified after execution has begun.")

		self.addDependencies(operations)
		return self
	}

	
	// MARK: Execution and Cancellation
	
	override final public func start() {
		// If the operation has been cancelled, we still need to enter the "Finished" state.
		if isCancelled {
			finish([])
		}

		// NSOperation.start() contains important logic that shouldn't be bypassed.
		super.start()
		
	}
	
	override final public func main() {
		assert(state == .ready, "This operation must be performed on an operation queue.")
		
		if internalErrors.isEmpty && !isCancelled {
			state = .executing
			
			delegate?.operationDidStart(self)
			
			for observer in observers {
				observer.operationDidStart(self)
			}
			
			if AOperation.Debugger.printOperationsState {
				print("AOperation \(self.name ?? "\(type(of: self))") executed")
			}
			
			execute()
		}
		else {
			finish([])
		}
	}
	
	/**
	`execute()` is the entry point of execution for all `AOperation` subclasses.
	If you subclass `AOperation` and wish to customize its execution, you would
	do so by overriding the `execute()` method.
	
	At some point, your `AOperation` subclass must call one of the "finish"
	methods defined below; this is how you indicate that your operation has
	finished its execution, and that operations dependent on yours can re-evaluate
	their readiness state.
	*/
	open func execute() {
		
		if AOperation.Debugger.printOperationsState {
			print("AOperation  \(self.name ?? "\(type(of: self))") must override `execute()`.")
		}
		
		finish([])
	}
	
    public private(set) var publishedErrors: [AOperationError] = []
    
	fileprivate var serialQueue = DispatchQueue(label: "Aoperation_InternalErrors_SerialQueue")
	fileprivate var _internalErrors = [AOperationError]()
	
	fileprivate var internalErrors: [AOperationError] {
		get {
			serialQueue.sync {
				_internalErrors
			}

		}
		
		set {
			serialQueue.async {
				self._internalErrors = newValue
			}
		}
	}
	
	
	override open func cancel() {
		if isFinished {
			return
		}
		
		if !_cancelled {
			_cancelled = true
			
			if AOperation.Debugger.printOperationsState {
				print("AOperation \(self.name ?? "\(type(of: self))") cancelled")
			}
						
			// if state <= .ready we check errors of operation and finishing app automatically
			if state > .ready {
				finish([])
			}
			
		}

	}
	
	/// Adds the given operation to the queue
	/// - Parameter operation: A operation to add to the queue
	public final func produce(_ operation: Foundation.Operation) {
		for observer in observers {
			observer.operation(self, didProduceOperation: operation)
		}
	}
	
	// MARK: Finishing
	
	/**
	Most operations may finish with a single error, if they have one at all.
	This is a convenience method to simplify calling the actual `finish()`
	method. This is also useful if you wish to finish with an error provided
	by the system frameworks. As an example, see `DownloadEarthquakesOperation`
	for how an error from an `NSURLSession` is passed along via the
	`finishWithError()` method.
	*/
//	internal func finish(_ error: AOperationError? = nil) {
//		if let error = error {
//			finish([error])
//		}
//		else {
//			finish([])
//		}
//	}
	
	/**
	A private property to ensure we only notify the observers once that the
	operation has finished.
	*/
	fileprivate var hasFinishedAlready = false
	
	internal final func finish(_ errors: [AOperationError]) {
		var errors: [AOperationError] = errors.map({ var error = $0; error.state = .execution; error.publisher = error.publisher ?? name; return error })
		
		if !hasFinishedAlready {
			hasFinishedAlready = true
			
			if isCancelled {
				var error = AOperationError.isCancelled(self)
				error.state = .execution
				error.publisher = self.name
				
				errors.append(error)
			}
			
			state = .finishing
			
			let combinedErrors = internalErrors + errors
            self.publishedErrors = combinedErrors
			
			state = .finished
			
			finished(combinedErrors)
			delegate?.operationDidFinish(self, with: combinedErrors)
			
			if AOperation.Debugger.printOperationsState {
				print("AOperation \(self.name ?? "\(type(of: self))") finished")
			}
			
			for observer in observers {
				observer.operationDidFinish(self, errors: combinedErrors)
			}
		}
	}
	
	/**
	Subclasses may override `finished(_:)` if they wish to react to the operation
	finishing with errors.
	*/
	internal func finished(_ errors: [AOperationError]) {
		// No op.
	}
	
	override final public func waitUntilFinished() {
		/*
		Waiting on operations is almost NEVER the right thing to do. It is
		usually superior to use proper locking constructs, such as `dispatch_semaphore_t`
		or `dispatch_group_notify`, or even `NSLocking` objects. Many developers
		use waiting when they should instead be chaining discrete operations
		together using dependencies.
		
		To reinforce this idea, invoking `waitUntilFinished()` will crash your
		app, as incentive for you to find a more appropriate way to express
		the behavior you're wishing to create.
		*/
		fatalError("Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.")
	}
	
	/// Observes when operation starts to executing
	/// - Parameter startHandler: A closure called when operation starts to executing
	@discardableResult
	public final func didStart(_ startHandler: @escaping (() -> Void)) -> Self {
		let observer: BlockObserver? = self.removeExistingBlockObserver()
		
		self.addObserver(BlockObserver(startHandler: { op in
			observer?.operationDidStart(op)
			startHandler()
		},
		produceHandler: {observer?.operation($0, didProduceOperation: $1)}, finishHandler: {observer?.operationDidFinish($0, errors: $1)}))
		return self
	}
	
//	@discardableResult
//	private func didFinish(_ finishHandler: @escaping (([AOperationError]) -> Void)) -> Self {
//		
//		let observer: BlockObserver? = self.removeExistingBlockObserver()
//		
//		self.addObserver(BlockObserver(startHandler: observer?.operationDidStart(_:),
//			produceHandler: {observer?.operation($0, didProduceOperation: $1)}, finishHandler: { operation, errors in
//			observer?.operationDidFinish(operation, errors: errors)
//			finishHandler(errors)
//		}))
//		return self
//	}
	
	/// Observes if operatoin produced another operation. means added it to its operationQueue
	/// - Parameter produceHandler: A closure called if operation produce another operation
	@discardableResult
	public func didProduce(_ produceHandler: @escaping ((Foundation.Operation) -> Void)) -> Self {
		
		let observer: BlockObserver? = self.removeExistingBlockObserver()
		
		self.addObserver(BlockObserver(startHandler: observer?.operationDidStart(_:), produceHandler: { (currentOperation, operation) in
			observer?.operation(currentOperation, didProduceOperation: operation)
			produceHandler(operation)
		}, finishHandler: {observer?.operationDidFinish($0, errors: $1)}))
		return self
	}
	
	/// Adds  operation to the specified queue.
	/// - Parameter queue: The queue operation added to
	///
	/// This method also adds upstream operation of the chain to the queue.
	@discardableResult
	public final func add(to queue: AOperationQueue) -> Self {
		let upstreamDependency = self.dependencies.first(where: {($0 as? AOperation)?.publisherId == subscriberId})
		
		if let op = upstreamDependency as? AOperation {
			op.add(to: queue)
		}
		queue.addOperation(self)
		return self
	}

	
	private final func removeExistingBlockObserver() -> BlockObserver? {
		assert(state < .executing, "Cannot modify observers after execution has begun.")
		
		var observer: BlockObserver?
		if let index = self.observers.firstIndex(where: { $0 is BlockObserver }) {
			observer = self.observers.remove(at: index) as? BlockObserver
		}
		return observer
	}
	
	func retry() {
		// This method is for overriding with subclass ResultableOperation
		fatalError("This method is for overriding with subclass ResultableOperation")
	}
	
	func retryAsFailedDependency(of operation: AOperation) {
		// This method is for overriding with subclass ResultableOperation
	}
	
	deinit {
		if AOperation.Debugger.printOperationsState {
			print("AOperation \(self.name ?? "\(type(of: self))") deinit")
		}
	}

	
}

// Simple operator functions to simplify the assertions used above.
private func <(lhs: AOperation.State, rhs: AOperation.State) -> Bool {
	return lhs.rawValue < rhs.rawValue
}

private func ==(lhs: AOperation.State, rhs: AOperation.State) -> Bool {
	return lhs.rawValue == rhs.rawValue
}


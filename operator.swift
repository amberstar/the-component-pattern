//
// Operator.swift
// Copyright © 2016 Amber Star. All rights reserved.
//

//===----------------------------------------------------------------------===//
//// MARK: - Operator
//===----------------------------------------------------------------------===//

/// A type that operates on values possibly producing a different type,
/// or no value at all.

public protocol Operator  {
    
    associatedtype Input
    associatedtype Output
    
    
    /// Operates and produces the next value with the specified input.
    mutating func next(_ input: Input) -> Output?
    
    /// Composes a target operator with `self` and returns a new operator.
    func compose<Target: Operator>(_ : Target) -> Function<Input, Target.Output> where Target.Input == Output
}

extension Operator {
    
    /// Composes a target operator with `self` returning a
    /// new operator.
    public func compose<Target: Operator> (_ target: Target) -> Function<Input, Target.Output> where Target.Input == Output
    {
        var base = target
        var captured = self
        
        return Function<Input, Target.Output> {
            guard let out = captured.next($0) else {
                return nil
            }
            return base.next(out)
        }
    }
}
//===----------------------------------------------------------------------===//
//// MARK: - Value
//===----------------------------------------------------------------------===//

///An operator that performs an action,
/// and produces it's input.
public struct Value<Element> : Operator {
    
    let value: Element
    public func next(_ input: Element) -> Element? {
               return value
    }
    
    /// Create an action with the specified action function.
    public init(_ v: Element) {
        value = v
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Action
//===----------------------------------------------------------------------===//

///An operator that performs an action,
/// and produces it's input.
public struct Action<Element> : Operator {
    
    var action : (Element) -> ()
    
    public func next(_ input: Element) -> Element? {
        action(input)
        return input
    }
    
    /// Create an action with the specified action function.
    public init(action: @escaping (Element) -> ()) {
        self.action = action
    }
}

extension Operator {
    
    /// perform an action with the specified function
    public func action(_ action: @escaping (Output) -> Void ) -> Function<Input, Output> {
        return self.compose (Action(action: action))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Branch
//===----------------------------------------------------------------------===//

extension Operator {
    
    /// branch to another operator then continue on with origional operator
    public func branch<T>(_ target: Function<Output, T>) -> Function<Input, Output> {
        var targetv = target
        let branch =  Function<Output, Output> {
            _ = targetv.next($0) ; return $0
        }
        return compose (branch)
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Combine
//===----------------------------------------------------------------------===//

/// An operator that combined it's input with the output of an embeded operator
/// producing a tuple of the initial input, and the output of the combinded operator.
public struct Combine<Input, T> : Operator {
    public typealias Output = (Input, T)
    public typealias Combinator = (Input) -> (Input, T)?
    
    var combinator: Combinator
    
    public mutating func next(_ input: Input) -> Output? {
       return combinator(input)
    }
    
    public init<O: Operator>(with o: O) where O.Input == Input, O.Output == T {
        var op = o
        self.init { op.next($0) }
    }

    public init(with f: @escaping (Input) -> T?) {
        let f: Combinator = { input in
            if let nxt = f(input) {
                return (input, nxt)
            }
            else { return nil }
        }
        combinator = f
    }
    
    public init(with combinator: @escaping Combinator) {
        self.combinator = combinator
    }
}

extension Operator {
    
    ///combine with the output of the specified operator producing a tuple
    public func combine<T, O: Operator>(with: O) -> Function<Input, (Output, T)> where O.Input == Output, O.Output == T {
        return compose(Combine<Output, T>(with: with))
    }
    
    public func combine<T>(with: @escaping (Output) -> (Output, T)?) -> Function<Input, (Output, T)> {
        return compose(Combine<Output, T>(with: with))
    }
    
    public func combine<T>(with: @escaping (Output) ->T?) -> Function<Input, (Output, T)> {
        return compose(Combine<Output, T>(with: with))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Reduce
//===----------------------------------------------------------------------===//

/// An stateful op that produces output by `combining` each input with
/// it's previous ouput.
public struct Reduce<Input,Output> : Operator {
    
    var accum : Output
    let combine : (Output, Input) -> Output
    
    public mutating func next(_ input: Input) -> Output? {
        accum = combine(accum, input)
        return accum
    }
    
    public init(_ initial: Output, _ combine: @escaping (Output, Input) -> Output) {
        self.accum = initial
        self.combine = combine
    }
}

extension Operator {
    
    /// produces the result of calling `combine` on each input
    public func reduce<T>(_ initial: T, _ combine: @escaping (T, Output) -> T) -> Function<Input, T> {
        return compose(Reduce(initial, combine))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Add
//===----------------------------------------------------------------------===//

extension Operator where Self.Output == Double {
    /// produce a count of output
    public func add() -> Function<Input, Double> {
        return compose (Reduce<Double, Double>(0) { accum, elem in
            return accum + elem
            })
    }
}

extension Operator where Self.Output == Int {
    /// produce a count of output
    public func add() -> Function<Input, Int> {
        return compose (Reduce<Int, Int>(0) { accum, elem in
            return accum + elem
        })
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Count
//===----------------------------------------------------------------------===//

/// An operator that produces the a count of it's input
public struct Count<In> : Operator {
    var count : Int = 0
    
    public mutating func next(_ : In) -> Int? {
        count += 1
        return self.count
    }
}

extension Operator {
    /// produce a count of output
    public func count() -> Function<Input, Int> {
        return compose (Count())
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Default
//===----------------------------------------------------------------------===//

extension Operator {
    
    // ensure output by specifying a default value to produce
    public func defaultTo(_ value: Output) -> Function<Input, Output> {
        var captured = self
        return Function<Input, Output> {
            guard let out = captured.next($0) else { return value }
            return out
        }
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Discard
//===----------------------------------------------------------------------===//

/// An operator that discards all input and produces void
///
/// note: this is not the same as producing nothing at all.
public struct Discard<Input> : Operator {
    
    public func next(_ input: Input) -> Void? { return Void() }
    public init() { }
}

extension Operator {
    
    /// discard values and produce void
    public func discard() -> Function<Input, Void> {
        return produce(Swift.Void())
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Distinct
//===----------------------------------------------------------------------===//

/// An operator that produces consecutively distinct output.
public struct Distinct<Element> : Operator {
    
    var last : Element?
    var isDistinct: (Element, Element) -> Bool
    
    public mutating func next(_ input: Element) -> Element? {
        guard let last = last else { self.last = input ; return input  }
        guard !isDistinct(last, input) else { return nil }
        
        self.last = input
        return input
    }
    
    /// Creates an instance with the specified predicate.
    public init (isDistinct predicate: @escaping (Element, Element) -> Bool  ) {
        self.isDistinct = predicate
        self.last = nil
    }
}

extension Distinct where Element : Equatable {
    
    public init() {
        self.init{ $0 == $1 }
    }
}

extension Operator {
    
    /// Produce consecutively distinct output with a predicate.
    public func distinct(isDistinct predicate: @escaping (Output, Output) -> Bool ) -> Function<Input, Output> {
        return compose(Distinct<Output>(isDistinct: predicate))
    }
}

extension Operator where Output: Equatable {
    
    /// Produce consecutively distinct output.
    public func distinct() -> Function<Input, Output> {
        return compose(Distinct<Output>())
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Filter
//===----------------------------------------------------------------------===//

/// An operator that filters input and produces output that satifies a predicate.
public struct Filter<Element> : Operator {
    public typealias In = Element
    public typealias Out = Element
    
    var predicate : (Element) -> Bool
    
    public func next(_ input: Element) -> Element? {
        return  predicate(input) ? input : nil
    }
    
    /// Creates an instance using the specified predicicate function.
    public init(_ includeElement: @escaping (Element) -> Bool ) {
        self.predicate = includeElement
    }
}

extension Operator {
    /// Produce output that satifies a predicate.
    public func filter(_ include: @escaping (Output) -> Bool ) -> Function<Input, Output> {
        return compose(Filter(include))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Evaluate
//===----------------------------------------------------------------------===//

public typealias Evaluation<Element> = (value: Element, result: Bool)
public typealias Evaluator<I, O> = Function<I, Evaluation<O>>

/// An operator that produces true if a goal has been reached
public struct Evaluate<Element> : Operator {
    public typealias Input = Element
    public typealias Output = Evaluation<Input>
    
    var predicate : (Element) -> Bool
    
    public func next(_ input: Element) -> Evaluation<Input>? {
        return  (input, predicate(input))
    }
    
    /// Creates an instance using the specified predicicate function.
    public init(predicate: @escaping (Element) -> Bool ) {
        self.predicate = predicate
    }
}

extension Operator {
    /// Produce output that satifies a predicate.
    public func evaluate(_ predicate: @escaping (Output) -> Bool ) -> Function<Input, Evaluation<Output>> {
        return compose(Evaluate(predicate: predicate))
    }
    
//    /// Produce output that satifies a predicate.
//    public func evaluate(predicate: @escaping (Value<Output>) -> Bool ) -> Function<Input, Evaluation<Output>> {
//        return compose(Evaluate { predicate(Value($0))}
//        )
//    }
}

extension Operator where Self.Output: Equatable {
    public func isEquals(to value: Self.Output) -> Function<Input, Evaluation<Output>> {
        return compose(Evaluate(predicate: { $0 == value}))
    }
}

extension Operator where Self.Output: Comparable {
    public func isGreater(than value: Self.Output) -> Function<Input, Evaluation<Output>> {
        return compose(Evaluate(predicate: { $0 > value}))
    }
    
    public func isLess(than value: Self.Output) -> Function<Input, Evaluation<Output>> {
        return compose(Evaluate(predicate: { $0 > value}))
    }
}


//===----------------------------------------------------------------------===//
//// MARK: - Function
//===----------------------------------------------------------------------===//

/// An operator that uses a function to generate output.
///
/// This is distinct from Map in that it uses it's
/// generator function to determine if it should produce
/// output.
public struct Function<In, Out> : Operator {
    public typealias Input = In
    public typealias Output = Out
    
    var generate : (Input) -> Output?
    
    public mutating  func next(_ input: Input) -> Output? {
        return generate(input)
    }
    
    /// Create an instance with the specified generator function.
    public init(_ generator: @escaping (Input) -> Output?) {
        self.generate = generator
    }
}

extension Operator {
    
    /// Apply a function over values using a generator function.
    public func function<T>(_ generator: @escaping (Output) -> T?) -> Function<Input, T> {
        return compose(Function(generator))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Limit
//===----------------------------------------------------------------------===//

/// An operator that produces a limited number of elements.
public struct Limit<Element> : Operator {
    
    var limit : UInt
    
    public mutating func next(_ input: Element) -> Element? {
        guard limit != 0 else { return nil }
        limit -= 1
        return input
    }
    
    /// Creates an instance with the specified limit.
    public init(_ limit: UInt) {
        self.limit = limit
    }
}

extension Operator {
    
    /// Produce a limited number of output elements.
    public func limit(_ number: UInt) -> Function<Input, Output> {
        return compose(Limit(number))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Map
//===----------------------------------------------------------------------===//

/// An operator that produces the result of mapping transform over it's input
public struct Map<Input, Output> : Operator {
    
    var transform : (Input) -> Output
    
    public func next(_ input: Input) -> Output? {
        return  transform(input)
    }
    
    public init(_ transform: @escaping (Input) -> Output ) {
        self.transform = transform
    }
}

extension Operator {
    
    /// produces the result of mapping transform over it's input
    public func map<T>(_ transform: @escaping (Output) -> T) -> Function<Input, T> {
        return compose(Map(transform))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Produce
//===----------------------------------------------------------------------===//

/// An operator that produces output using a producer function
public struct Produce<Out> : Operator {
    
    var producer : () -> Out
    
    public mutating func next(_ input: ()) -> Out? {
        return producer()
    }
    /// Creates an instance with the specified producer function.
    public init( _ producer: @autoclosure @escaping  () -> Out ) {
        self.producer = producer
    }
}

extension Operator {
    
    /// Produce output with a producer function.
    public func produce<Output>( _ producer: @autoclosure @escaping  () -> Output ) -> Function<Input, Output> {
        return self.map {_ in return Void() }.compose(Produce(producer))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Take
//===----------------------------------------------------------------------===//

///An operator which always produces it's input
public struct Take<Element> : Operator {
    
    public func next(_ input: Element) -> Element? {
        return input
    }
    public init() {}
}

//===----------------------------------------------------------------------===//
//// MARK: - Utilities
//===----------------------------------------------------------------------===//

extension Operator {
    
    /// Print all elements upon ouput.
    public func print() -> Function<Input, Output> {
        return action { Swift.print($0) }
    }
    
    /// Print a string upon output that is produced with a specified function.
    public func print(_ with: @escaping (Output) -> String ) -> Function<Input, Output> {
        return action { Swift.print(with($0)) }
    }
    
    /// Print a specific string upon output.
    public func print(_ with: String) ->  Function<Input, Output> {
        return action { _ in Swift.print(with) }
    }
    
    /// Produce the data upon output.
    public func date() -> Function<Input, Date> {
        return produce(Date())
    }
}

extension Operator where Output: CustomStringConvertible {
    
    /// Produce a description of all elements.
    public func description() -> Function<Input, String> {
        return map { $0.description }
    }
}

extension Operator where Output: CustomDebugStringConvertible {
    
    /// Produce the debug description of all elements going downstream.
    public func debugDescription() -> Function<Input, String> {
        return map { $0.debugDescription }
    }
}

extension Operator where Output == String {
    
    /// Prefix all elements going downstream with a string.
    public func prefix(_ with: String) -> Function<Input, String> {
        return map { with + $0 }
    }
}

extension Operator where Output == Bool {
    /// Produce the negation of output.
    public func not() -> Function<Input, Bool> {
        return map { !$0 }
    }
}
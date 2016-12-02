
//
// Component: Experimental.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

//===----------------------------------------------------------------------===//
//// MARK: - Combine
//===----------------------------------------------------------------------===//

/// An operator that combined it's input with the output of an embedded operator
/// producing a tuple of the initial input, and the output of the combined operator.
public struct Combine<Element, T> : OperatorProtocol {
    //public typealias Output = (Element, T)
    public typealias Combinator = (Element) -> (Element, T)?
    
    var combinator: Combinator
    
    public mutating func input(_ element: Element) -> (Element, T)? {
        return combinator(element)
    }
    
    public init<O:OperatorProtocol>(with o: O) where O.Input == Element, O.Output == T {
        var op = o
        self.init { op.input($0) }
    }
    
    public init(with f: @escaping (Element) -> T?) {
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

extension OperatorProtocol {
    
    ///combine with the output of the specified operator producing a tuple
    public func combine<T, O:OperatorProtocol>(with: O) -> Operator<Input, (Output, T)> where O.Input == Output, O.Output == T {
        return compose(Combine<Output, T>(with: with))
    }
    
    public func combine<T>(with: @escaping (Output) -> (Output, T)?) -> Operator<Input, (Output, T)> {
        return compose(Combine<Output, T>(with: with))
    }
    
    public func combine<T>(with: @escaping (Output) ->T?) -> Operator<Input, (Output, T)> {
        return compose(Combine<Output, T>(with: with))
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Branch
//===----------------------------------------------------------------------===//

extension OperatorProtocol {
    
    /// branch to another operator then continue on with original operator
    public func branch<T>(_ target: Operator<Output, T>) -> Operator<Input, Output> {
        var targetv = target
        let branch =  Operator<Output, Output> {
            _ = targetv.input($0) ; return $0
        }
        return compose (branch)
    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Evaluate
//===----------------------------------------------------------------------===//

public typealias Evaluation<Element> = (value: Element, result: Bool)
public typealias Evaluator<I, O> = Operator<I, Evaluation<O>>

/// An operator that produces true if a goal has been reached
public struct Evaluate<Element> : OperatorProtocol {
    var predicate : (Element) -> Bool
    
    public func input(_ element: Element) -> Evaluation<Element>? {
        return  (element, predicate(element))
    }
    
    /// Creates an instance using the specified predicate function.
    public init(predicate: @escaping (Element) -> Bool ) {
        self.predicate = predicate
    }
}

extension OperatorProtocol {
    /// Produce output that satisfies a predicate.
    public func evaluate(_ predicate: @escaping (Output) -> Bool ) -> Operator<Input, Evaluation<Output>> {
        return compose(Evaluate(predicate: predicate))
    }
    
    //    /// Produce output that satisfies a predicate.
    //    public func evaluate(predicate: @escaping (Value<Output>) -> Bool ) -> Function<Input, Evaluation<Output>> {
    //        return compose(Evaluate { predicate(Value($0))}
    //        )
    //    }
}

//===----------------------------------------------------------------------===//
//// MARK: - Default
//===----------------------------------------------------------------------===//

extension OperatorProtocol {
    
    // ensure output by specifying a default value to produce
    public func defaultTo(_ value: Output) -> Operator<Input, Output> {
        var captured = self
        return Operator<Input, Output> {
            guard let out = captured.input($0) else { return value }
            return out
        }
    }
}




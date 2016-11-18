
//
// Component: Operator.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// A type that operates on values possibly producing a different type,
/// or no value at all.

public protocol OperatorProtocol {
    associatedtype Input
    associatedtype Output
    
    /// Operates and produces the next value with the specified input.
    mutating func input(_ input: Input) -> Output?
    
    /// Composes a target operator with `self` and returns a new operator.
    func compose<Target:OperatorProtocol>(_ : Target) -> Operator<Input, Target.Output> where Target.Input == Output
}

extension OperatorProtocol {
    
    /// Composes a target operator with `self` returning a
    /// new operator.
    public func compose<Target:OperatorProtocol> (_ target: Target) -> Operator<Input, Target.Output> where Target.Input == Output
    {
        var base = target
        var captured = self
        
        return Operator<Input, Target.Output> {
            guard let out = captured.input($0) else {
                return nil
            }
            return base.input(out)
        }
    }
}

/// An operator type that uses a process function to generate output.
///
/// This is distinct from Map in that it uses it's
/// generator function to determine if it should produce
/// output.
public struct Operator<Input, Output> : OperatorProtocol {
    var process : (Input) -> Output?

    public mutating  func input(_ input: Input) -> Output? {
        return process(input)
    }

    /// Create an instance with the specified generator function.
    public init(_ process: @escaping (Input) -> Output?) {
        self.process = process
    }
}

extension OperatorProtocol {
    
    /// Apply a function over values using a generator function.
    public func operate<T>(_ generator: @escaping (Output) -> T?) -> Operator<Input, T> {
        return compose(Operator(generator))
    }

}


//
// Component: Filter.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// An operator that filters input and produces output that satisfies a predicate.
public struct Filter<Element> : OperatorProtocol {
    var predicate : (Element) -> Bool
    
    public func input(_ element: Element) -> Element? {
        return  predicate(element) ? element : nil
    }
    
    /// Creates an instance using the specified predicate function.
    public init(_ isIncluded: @escaping (Element) -> Bool ) {
        self.predicate = isIncluded
    }
}

extension OperatorProtocol {
    /// Produce output that satisfies a predicate.
    public func filter(_ isIncluded: @escaping (Output) -> Bool ) -> Operator<Input, Output> {
        return compose(Filter(isIncluded))
    }
}


extension OperatorProtocol where Self.Output: Equatable {
    public func isEquals(to value: Self.Output) -> Operator<Input, Evaluation<Output>> {
        return compose(Evaluate(predicate: { $0 == value}))
    }
}

extension OperatorProtocol where Self.Output: Comparable {
    public func isGreater(than value: Self.Output) -> Operator<Input, Evaluation<Output>> {
        return compose(Evaluate(predicate: { $0 > value}))
    }
    
    public func isLess(than value: Self.Output) -> Operator<Input, Evaluation<Output>> {
        return compose(Evaluate(predicate: { $0 > value}))
    }
}

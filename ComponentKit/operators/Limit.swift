
//
// Component: Limit.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// An operator that produces a limited number of elements.
public struct Limit<Element> : OperatorProtocol {
    var limit : UInt
    
    public mutating func input(_ element: Element) -> Element? {
        guard limit != 0 else { return nil }
        limit -= 1
        return element
    }
    
    /// Creates an instance with the specified limit.
    public init(_ limit: UInt) {
        self.limit = limit
    }
}

extension OperatorProtocol {
    
    /// Produce a limited number of output elements.
    public func limit(_ number: UInt) -> Operator<Input, Output> {
        return compose(Limit(number))
    }
}

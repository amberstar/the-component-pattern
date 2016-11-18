
//
// Component: Distinct.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// An operator that produces consecutively distinct output.
public struct Distinct<Element> : OperatorProtocol {
    var last : Element?
    var isDistinct: (Element, Element) -> Bool
    
    public mutating func input(_ element: Element) -> Element? {
        guard let last = last else { self.last = element ; return element  }
        guard !isDistinct(last, element) else { return nil }
        
        self.last = element
        return element
    }
    
    /// Creates an instance with the specified predicate.
    public init (isDistinct predicate: @escaping (Element, Element) -> Bool  ) {
        self.isDistinct = predicate
        self.last = nil
    }
}

extension Distinct where Element: Equatable {
    
    public init() {
        self.init{ $0 == $1 }
    }
}

extension OperatorProtocol {
    
    /// Produce consecutively distinct output with a predicate.
    public func distinct(isDistinct predicate: @escaping (Output, Output) -> Bool ) -> Operator<Input, Output> {
        return compose(Distinct<Output>(isDistinct: predicate))
    }
}

extension OperatorProtocol where Output: Equatable {
    
    /// Produce consecutively distinct output.
    public func distinct() -> Operator<Input, Output> {
        return compose(Distinct<Output>())
    }
}

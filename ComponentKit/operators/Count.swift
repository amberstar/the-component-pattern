
//
// Component: Count.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// An operator that produces the a count of it's input
public struct Count<Element> : OperatorProtocol {
    var count : Int = 0
    
    public mutating func input(_ element: Element) -> Int? {
        count += 1
        return self.count
    }
}

extension OperatorProtocol {
    /// produce a count of output
    public func count() -> Operator<Input, Int> {
        return compose (Count())
    }
}

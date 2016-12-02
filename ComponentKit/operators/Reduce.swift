//
// Component: Reduce.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// An stateful operator that produces output by `combining` each input with
/// it's previous output.
public struct Reduce<Element, Result> : OperatorProtocol {
    var accum : Result
    let combine : (Result, Element) -> Result
    
    public mutating func input(_ element: Element) -> Result? {
        accum = combine(accum, element)
        return accum
    }
    
    public init(_ initial: Result, _ combine: @escaping (Result, Element) -> Result) {
        self.accum = initial
        self.combine = combine
    }
}

extension OperatorProtocol {
    
    /// produces the result of calling `combine` on each input
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: @escaping (Result, Output) -> Result) -> Operator<Input, Result> {
        return compose(Reduce(initialResult, nextPartialResult))
    }
}

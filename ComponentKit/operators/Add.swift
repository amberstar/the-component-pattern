
//
// Component: Add.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

extension OperatorProtocol where Self.Output == Double {
    /// produce a count of output
    public func add() -> Operator<Input, Double> {
        return compose (Reduce<Double, Double>(0) { accum, elem in
            return accum + elem
        })
    }
}

extension OperatorProtocol where Self.Output == Int {
    /// produce a count of output
    public func add() -> Operator<Input, Int> {
        return compose (Reduce<Int, Int>(0) { accum, elem in
            return accum + elem
        })
    }
}


//
// Component: Discard.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// An operator that discards all input and produces void
///
/// note: this is not the same as producing nothing at all.
public struct Discard<Element> : OperatorProtocol {
    
    public func input(_ element: Element) -> Void? { return Void() }
    public init() { }
}

extension OperatorProtocol {
    
    /// discard values and produce void
    public func discard() -> Operator<Input, Void> {
        return produce(Swift.Void())
    }
}

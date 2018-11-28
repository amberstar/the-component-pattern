
//
// Component: Value.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

///An operator that performs an action,
/// and produces its input.
public struct Value<T> : OperatorProtocol {
    let value: T
    
    public func input(_ value: T) -> T? {
        return value
    }
    
    /// Create an action with the specified action function.
    public init(value: T) {
        self.value = value
    }
}


//
// Component: Map.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// An operator that produces the result of mapping transform over its input
public struct Map<Element, T> : OperatorProtocol {
    
    var transform : (Element) -> T
    
    public func input(_ element: Element) -> T? {
        return  transform(element)
    }
    
    public init(_ transform: @escaping (Element) -> T) {
        self.transform = transform
    }
}

extension OperatorProtocol {
    
    /// produces the result of mapping transform over its input
    public func map<T>(_ transform: @escaping (Output) -> T) -> Operator<Input, T> {
        return compose(Map(transform))
    }
}

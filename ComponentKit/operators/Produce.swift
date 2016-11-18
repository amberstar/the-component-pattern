
//
// Component: Produce.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

/// An operator that produces output using a producer function
public struct Produce<Element> : OperatorProtocol {
    var producer : () -> Element
    
    public mutating func input(_ any: ()) -> Element? {
        return producer()
    }
    /// Creates an instance with the specified producer function.
    public init( _ producer: @autoclosure @escaping  () -> Element) {
        self.producer = producer
    }
}

extension OperatorProtocol {
    /// Produce output with a producer function.
    public func produce<Output>( _ producer: @autoclosure @escaping  () -> Output ) -> Operator<Input, Output> {
        return self.map {_ in return Void() }.compose(Produce(producer))
    }
}

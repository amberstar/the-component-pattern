
//
// Component: Utility.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//
import Foundation
extension OperatorProtocol {
    
    /// Print all elements upon ouput.
    public func print() -> Operator<Input, Output> {
        return action { Swift.print($0) }
    }
    
    /// Print a string upon output that is produced with a specified function.
    public func print(_ with: @escaping (Output) -> String ) -> Operator<Input, Output> {
        return action { Swift.print(with($0)) }
    }
    
    /// Print a specific string upon output.
    public func print(_ with: String) ->  Operator<Input, Output> {
        return action { _ in Swift.print(with) }
    }
    
    /// Produce the data upon output.
    public func date() -> Operator<Input, Date> {
        return produce(Date())
    }
}

extension OperatorProtocol where Output: CustomStringConvertible {
    
    /// Produce a description of all elements.
    public func description() -> Operator<Input, String> {
        return map { $0.description }
    }
}

extension OperatorProtocol where Output: CustomDebugStringConvertible {
    
    /// Produce the debug description of all elements going downstream.
    public func debugDescription() -> Operator<Input, String> {
        return map { $0.debugDescription }
    }
}

extension OperatorProtocol where Output == String {
    
    /// Prefix all elements going downstream with a string.
    public func prefix(_ with: String) -> Operator<Input, String> {
        return map { with + $0 }
    }
}

extension OperatorProtocol where Output == Bool {
    /// Produce the negation of output.
    public func not() -> Operator<Input, Bool> {
        return map { !$0 }
    }
}

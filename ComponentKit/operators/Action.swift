//
// Component: Action.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

///An operator that performs an action,
/// and produces its input.
public struct Action<Input> : OperatorProtocol {
    var action : (Input) -> ()
    
    public func input(_ input: Input) -> Input? {
        action(input)
        return input
    }
    
    /// Create an action with the specified action function.
    public init(action: @escaping (Input) -> ()) {
        self.action = action
    }
}

extension OperatorProtocol {
    
    /// perform an action with the specified function
    public func action(_ action: @escaping (Output) -> Void ) -> Operator<Input, Output> {
        return self.compose (Action(action: action))
    }
}

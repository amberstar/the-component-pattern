
//
// Component: Take.swift
// Copyright © 2016 SIMPLETOUCH LLC. All rights reserved.
//

///An operator which always produces it's input
public struct Take<Input> : OperatorProtocol {
    
    public func input(_ input: Input) -> Input? {
        return input
    }
    public init() {}
}

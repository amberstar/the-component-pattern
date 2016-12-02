//
// Component: Time.swift
// Copyright © 2016 SIMPLETOUCH LLC, All rights reserved.
//

import Foundation
public struct Runtime : OperatorProtocol {
    private typealias TimeProcess = (TimeInterval, CFAbsoluteTime, CFAbsoluteTime) -> (CFAbsoluteTime, TimeInterval)

    private final class TimeProcessor {
        static var firstProcess: TimeProcess = { time, timestamp, _ in
            return (timestamp, time)
        }
        static var normalProcess: TimeProcess = { time, timestamp, previousTimestamp in
            return (timestamp, time + (timestamp - previousTimestamp))
        }
        lazy var switchingProcess: TimeProcess = { return { time, timestamp, previousTimestamp in

            self._process = normalProcess
            return TimeProcessor.firstProcess(time, timestamp, previousTimestamp)

        }}()
        lazy var _process: TimeProcess = { return self.switchingProcess }()

        func process(time: TimeInterval, timestamp: CFAbsoluteTime, previousTimestamp: CFAbsoluteTime) -> (CFAbsoluteTime, TimeInterval) {
            return _process(time, timestamp, previousTimestamp)
        }
    }

    public private(set) var time: (timestamp: CFAbsoluteTime, time: TimeInterval)
    private var processor = TimeProcessor()

    public mutating func input(_ timestamp: CFAbsoluteTime) -> TimeInterval? {
        time = processor.process(time: time.time, timestamp: timestamp, previousTimestamp: time.timestamp)
        return time.time
    }

    /// Creates an instance with the specified timestamp and uptime in seconds.
    public init(timestamp: CFAbsoluteTime? = nil, uptime: TimeInterval = 0 ) {
        self.time = (timestamp: timestamp ?? CFAbsoluteTimeGetCurrent(), time: uptime)
    }
}

/// An operator that produces the current absolute time in seconds
public struct Timestamp : OperatorProtocol {

    public mutating func input(_ : Void) -> CFTimeInterval? {
        return CFAbsoluteTimeGetCurrent()
    }

    public init() {}
}

public struct TimeKeeper {
    private var op : Operator<(), Double>
    public private(set) var time: TimeInterval = 0

    public mutating func start() {
        time = op.input()!
    }

    public mutating func update() -> TimeInterval {
        return op.input()!
    }

    public mutating func reset() {
        op = Timestamp().compose(Runtime())
        time = 0
    }

    public init(time: TimeInterval = 0) {
        op = Timestamp().compose(Runtime(timestamp: time))
    }
}

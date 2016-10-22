# The Component Pattern

## A Component

![The Component Pattern](img/ComponentPattern.png)

## Components working together.
![Composition](img/Component2.png)
# Operators
Operators are single step automoton combinators. Operators take one single input value in, and produce output, or, nothing at all.

```swift
//===----------------------------------------------------------------------===//
//// MARK: - Operator
//===----------------------------------------------------------------------===//

/// A type that operates on values possibly producing a different type,
/// or no value at all.

public protocol Operator  {
    
    associatedtype Input
    associatedtype Output
    
    
    /// Operates and produces the next value with the specified input.
    mutating func next(_ input: Input) -> Output?
    
    /// Composes a target operator with `self` and returns a new operator.
    func compose<Target: Operator>(_ : Target) -> Function<Input, Target.Output> where Target.Input == Output
}
```

**The idea behind operators are simple:**
- what you do with input from a source should be decoupled from the mechanism in which it gets there.
- a useful abstraction is "as much process" with as little predifined content.

```swift
var myOperator = Take<MyStruct>().map{ format($0.myProperty) }.action { label.text = $0 }
```
We start with `Take` to declare we want to input `MyStruct`, we then perform a `map` and an `action`.  This defines a new `operator`. Now all we need to do is input values into the operator to produce a result. 

```swift

myOperator.next(myStruct) 

```

## Sample Operators 
(see `operator.swift` for more)

| `Operator`         | Description                                                                            |
|--------------------|----------------------------------------------------------------------------------------|
| `Take`          | Produces it's input                                                                    |
| `Limit`         | Produces it's input a limited number of times                                          |
| `Distinct`         | Produces distinct values relative to it's last output                                  |
| `Discard`          | Produces Void regardless of input                                                      |
| `Action`           | Performs an action with  and produces it's input                            |
| `Map`              | Produces the result of mapping a function over it's input                              |
| `Filter`           | Produces output that satisfies a predicate                                             |
| `Reduce`           | Produces the result of calling a `combine` function on each input and the last combine |
| `Produce`           | Produces a result from a producer function |
| `Count`            | Produces a count of it's input                                                         |
| `Branch`           | Branch with the current output, then continue on the main branch                       |
| `Combine`          | Combines it's input with the output of an operator producing a tuple      |
| `.print`            | Prints and produces it's input                                                             |
| `.description`      | Produces inputs description                                                            |
| `.debugDescription` | Produces the inputs debug description                                                  |
| `.prefix`           | Prefix the string input with a string                                                  |
| `.date`             | Produce a tuple with the input and a date                                              |
| `.defaultTo`             | Produce a default value if the no output is produced                              |

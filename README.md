# The Component Pattern

## What is the component pattern?
The component pattern is a simple experiment to reason about structure of software. It can be tried in varying degrees mostly by convention with exsiting types. The ideas here are not unique, in fact you will recognize the ideas and see them everywhere, and as far back Unix, Lisp, and probably before that.

The question is, is this a foundational concept that everyone should know?

Everything you need to know about the pattern is in the image below:


![Composition](img/Component2.png)

## What is a component?
A component is any composable type that has input, a process, and output. Another way to think about a component is as a pure function with multiple inputs and outputs. In the component pattern a pure function is considered a component. Functions are just one type of component.



# Operators
Operators are simple components that compose together to make new ones, just like any component composition. They take a single input value in,and may produce output, or, not. The not part is signifigant. It's not that operations do or don't output, it's that it may or it may not, depending on it's context and purpouse. For example a filter operator.

**The idea behind operators are simple:**
- a useful abstraction is "as much process with as little content as possible". 

```swift

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

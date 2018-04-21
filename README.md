# FunctionKit

[![Swift 4.1](https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat)](#)
[![Build Status](https://travis-ci.org/mpangburn/FunctionKit.svg?branch=master)](https://travis-ci.org/mpangburn/FunctionKit)
[![MIT](https://img.shields.io/packagist/l/doctrine/orm.svg)](https://github.com/mpangburn/FunctionKit/blob/master/LICENSE)
[![@pangburnout](https://img.shields.io/badge/contact-@pangburnout-blue.svg?style=flat)](https://twitter.com/pangburnout)

A framework for functional types and operations designed to fit naturally into Swift.

## Table of Contents

- [**Background**](#background)
- [**Goals**](#goals)
- [**Usage**](#usage)
    - [Functional Operations](#functional-operations)
        - [Forward Composition](#forward-composition)
        - [Concatenation](#concatenation)
        - [Optional Chaining](#optional-chaining)
        - [Backward Composition](#backward-composition)
        - [Currying](#currying)
        - [KeyPath Support](#keypath-support)
    - [Special Function Types](#special-function-types)
        - [`Consumer` and `Provider`](#consumer-and-provider)
        - [`Predicate`](#predicate)
        - [`Comparator`](#comparator)
    - [Inout Functions](#inout-functions)
    - [Throwing Functions](#throwing-functions)
- [**Installation**](#installation)
- [**References**](#references)
- [**License**](#license)

## Background

As a language with first-class functions, Swift supports the use of functions as values. This means that functions can be stored in variables and passed as arguments to other functions.

You've probably encountered some of Swift's functional API when working with sequences:

```swift
let numbers = 1...5
let incrementedNumbers = numbers.map { $0 + 1 }   // [2, 3, 4, 5, 6]
let evenNumbers = numbers.filter { $0 % 2 == 0 }  // [2, 4]
```

Sometimes it's desirable to perform multiple operations on a sequence:

```swift
let names = ["LAUREN  ", "michael", "JiM", "  Alison"]
let sanitizedNames = names
    .map(removeExtraWhitespace)
    .map(capitalizeProperly)
```

This seems nice, but we've introduced an inefficiency: in mapping over the array twice, we unnecessarily create an intermediate array. Here are a couple potential solutions:

1. Make the function calls together in a single map.
2. Use the `lazy` property.

Option 1 quickly becomes a parenthetical nightmare, and option 2 often hurts readability because of the need to subsequently call the `Array` initializer. Function composition can solve this problem elegantly:

```swift
let sanitize = Function(removeExtraWhitespace).piped(into: capitalizeProperly)
let sanitizedNames = names.map(sanitize)
```

What's happening here?

As powerful as Swift functions are, we unfortunately cannot write 

```swift
extension <A, B> (A) -> B {
    // implement a method for all functions of form (A) -> B
}
```

Instead, we use the `Function` type to wrap a Swift function and provide it with powerful new functionality—pun intended. The `piped(into:)` method creates a new function that takes the output of `removeExtraWhitespace` and uses it as the input for `capitalizeProperly`.

We can use composition to transform type, too:

```swift
let sanitizedCount = sanitize.piped(into: { $0.count })
let sanitizeNameCounts = names.map(sanitizedCount) // [Int]
```

By employing functions as composable, transformative units, we enhance modularity and expressivity. FunctionKit provides a number of tools to make working with functional types easy.

## Goals

- **Clarity** — FunctionKit aims for clarity at the point of use. Method names follow terms of art where appropriate but do not shy away from explicit descriptions of intent.
- **Intuitiveness** — By wrapping a Swift function in a `Function` object, it gains access to powerful functional operations such as composition and currying through clear, easily-discoverable instance methods.
- **Simplicity** — `Function` methods that take other `Function` objects as input have overloads to support Swift functions directly, and native Swift methods like `Sequence.map` have overloads to take `Function` objects. The result is a simpler, more intuitive, clearer API.

**Important:** It is a _non-goal_ of FunctionKit to turn Swift into a purely functional programming language. FunctionKit embraces and enhances Swift's functional capabilities in a way that fits naturally into the language.

FunctionKit favors the method dot-syntax of iterative languages over free functions or operators. For more traditional applications of functional programming constructs in Swift, see [Overture](https://github.com/pointfreeco/swift-overture), [Prelude](https://github.com/pointfreeco/swift-prelude), and [Swiftz](https://github.com/typelift/Swiftz).

## Usage

The principal unit of FunctionKit is the `Function` type, which wraps a Swift function.
Create a `Function` using its initializer:

```swift
let makeRandom = Function(arc4random_uniform)              // Function<UInt32, UInt32>
let stringFromData = Function(String.init(data:encoding:)) // Function<(Data, String.Encoding), String?>
let increment = Function { (x: Int) in x + 1 }             // Function<Int, Int>
```

Alternatively, use one of the static methods described later in this section to initialize a `Function` by composing several Swift functions.

To invoke a `Function`, use the `apply(_:)` method.

```swift
let random = makeRandom.apply(100)               // 42, perhaps
let parsed = stringFromData.apply(Data(), .utf8) // Optional<String>.some("")
let incremented = increment.apply(6)             // 7
```

Once wrapped in a `Function`, the gateway to powerful functional API is open.

### Functional Operations

The following functional operations are supported through the `Function` type:

#### Forward Composition

Forward composition is the process of creating a new function by piping the output of one function into another. The process of forward composition can be described as

`pipe` `(A) -> B` `(B) -> C` `=>` `(A) -> C`

To forward compose functions, use the `piped(into:)` method:

```swift
let sanitize = Function(removeExtraWhitespace).piped(into: capitalizeProperly) // Function<String, String>
```

A sequence of functions can be forward-composed using the static `pipeline` method:

```swift
let sanitizedCount = Function.pipeline(removeExtraWhitespace, capitalizeProperly, { $0.count }) // Function<String, Int>
```

#### Concatenation

Concatenation is forward composition of functions whose input and output types are the same. The process of concatenation can be described as

`concatenate` `(A) -> A` `(A) -> A` `=>` `(A) -> A`

While this functionality is fully provided by normal forward composition, it is immediately obvious at the callsite of a concatenation that type remains unchanged. As such, concatenation is a valuable operation for enhancing type safety and clarity of intent.

To concatenate functions, use the `concatenated(with:)` method:

```swift
let sanitize = Function(removeExtraWhitespace).concatenated(with: capitalizeProperly) // Function<String, String>
```

A sequence of functions can be concatenated with the static `concatenation` method:

```swift
let sanitize = Function.concatenation(removeExtraWhitespace, removeWeirdUnicodeCharacters, capitalizeProperly) // Function<String, String>
```

#### Optional Chaining

Chaining is forward composition of functions that return `Optional` values. If any function in the chain returns `nil`, the whole function returns `nil`. The process of chaining can be described as

`chain` `(A) -> B?` `(B) -> C?` `=>` `(A) -> C?`

To chain functions, use the `chained(with:)` method:

```swift
let urlStringHost = Function(URL.init(string:)).chained(with: { $0.host }) // Function<String, String?>
```

A sequence of `Optional`-returning functions can be chained using the static `chain` method:

```swift
let urlStringHostFirstCharacter = Function.chain(URL.init(string:), { $0.host }, { $0.first }) // Function<String, Character?>
```

#### Backward Composition

Backward composition is the process of creating a new function by applying a function to the output of another. The process of backwards composition can be described as

`compose` `(B) -> C` `(A) -> B` `=>` `(A) -> C`

While this functionality is fully provided by forward composition when the arguments are in the opposite order, it is sometimes more expressive to write code using backward composition. It may be useful to think of backward composition as "lifting" a function on one type to a function on another type.

To backward compose functions, use the `composed(with:)` method:

```swift
let sanitize = Function(capitalizeProperly).composed(with: removeExtraWhitespace) // Function<String, String>
```

A sequence of functions can be backward-composed with the static `composition` method:

```swift
let sanitizedCount = Function.composition({ $0.count }, removeExtraWhitespace, capitalizeProperly) // Function<String, Int>
```

#### Currying

Currying is the process of a splitting a function that takes a tuple input argument into a sequence of functions. The process of currying a two-argument function can be described as

`curry` `(A, B) -> C` `=>` `(A) -> (B) -> C`

A curried function takes a single argument and returns a function.

Currying is useful for partially applying a function, i.e. providing a value for one of its arguments to produce a function that takes one fewer argument.

For example, using the `curried()` method, we can curry and partially apply integer addition:

```swift
// CurriedTwoArgumentFunction<A, B, C> is a typealias for Function<A, Function<B, C>>.
let curriedAdd: CurriedTwoArgumentFunction<Int, Int, Int> = Function(+).curried()
let addToFive = curriedAdd.apply(5) // Function<Int, Int>
addToFive.apply(3)  // 8
addToFive.apply(20) // 25
```

When partially applying a function, it can be helpful to flip the order of its arguments using the `flippingFirstTwoArguments()` method:

```swift
// In describing the steps below, standard Swift function notation will be used over `Function` type notation 
// to demonstrate the operations performed more clearly.
let utf8StringFromData =
    Function(String.init(data:encoding:)) // (Data, String.Encoding) -> String?
        .curried()                        // (Data) -> (String.Encoding) -> String?
        .flippingFirstTwoArguments()      // (String.Encoding) -> (Data) -> String?
        .apply(.utf8)	                  // (Data) -> String?
```

While curried functions typically provide the most flexibility, it can be useful to uncurry a curried function. The process of uncurrying two arguments can be described as

`uncurry` `(A) -> (B) -> C` `=>` `(A, B) -> C`

For example, using the `uncurried()` method, we can uncurry an unapplied method reference:

```swift
let stringHasPrefix = String.hasPrefix                         // (String) -> (String) -> Bool 
let uncurriedHasPrefix = Function(stringHasPrefix).uncurried() // Function<(String, String), Bool> 
uncurriedHasPrefix.apply("function", "func")                   // true
```

**Note:** The behavior of unapplied method references may change if [SE-0042](https://github.com/apple/swift-evolution/blob/master/proposals/0042-flatten-method-types.md) is implemented.

#### KeyPath Support

The static `get` method takes in a `KeyPath<Root, Value>` and returns a function that extracts the value from the root.

```swift
// The following two functions have the same effect:
let getStringCount1: Function<String, Int> = .init { $0.count }
let getStringCount2 = Function.get(\String.count)
```

The static `update` method takes in a `WritableKeyPath<Root, Value>` and returns a setter function that propogates an update to the property of a type to an update to an instance of that type.

```swift
struct Person {
	var name: String
}

let updateName = Function.update(\Person.name)           // Function<Function<String, String>, Function<Person, Person>>
let lowercaseName = updateName.apply { $0.lowercased() } // Function<Person, Person>
let MICHAEL = Person(name: "MICHAEL")
let michael = lowercaseName.apply(MICHAEL)
// michael.name == "michael"
```

**Warning:** Using a function produced by `update` with mutable reference types may result in unexpected behavior.

### Special Function Types

Certain function types are particularly common for their uses in common tasks, such as filtering and sorting. FunctionKit provides additional API for the following types:

#### `Consumer` and `Provider`

The `Consumer` type is defined as

```swift
typealias Consumer<Input> = Function<Input, Void>
```

The `Consumer` type describes a function that produces no output, such as one that modifies state or logs data. `Consumer` instances can be chained with the `then(_:)` method:

```swift
let handleError = Consumer<Error>
    .init(presentError)
    .then(analyticsManager.logError)
```

The `Consumer` type is appropriate for use with mutable reference types:

```swift
let configureLabel = Consumer<UILabel>
    .init(stylizeFont)
    .then { $0.numberOfLines = 0 }
    .then(view.addSubview)
	
configureLabel.apply(detailLabel)
```

**Note:** `Consumer` is _not_ designed to model `inout` functions, which mutate value types. [A separate class](#inout-functions) exists for this purpose.

The `Provider` type is defined as

```swift
typealias Provider<Output> = Function<Void, Output>
```

The `Provider` type describes factory methods that can produce output without being passed input. They can be invoked with the `make()` method:

```swift
let timestampProvider = Provider(Date.init)
let now = timestampProvider.make()

let idProvider = Provider(IdentifierFactory.makeId)
let id = idProvider.make()
```

#### `Predicate`

The `Predicate` type is defined as

```swift
typealias Predicate<Input> = Function<Input, Bool>
```

`Predicate` instances are useful for validating input and filtering. They can be invoked with the `test(_:)` method, negated with the `negated()` method or the prefix `!` operator, and logically combined with the infix `&&` and `||` operators.

Because certain predicates are so common, additional static functions like `isEqualTo(_:)`, `isLessThan(_:)`, and `isInRange(_:)` are also provided.

```swift
let hasValidLength: Predicate<String> = Function
    .get(\String.count)
    .piped(into: .isInRange(4...12))

let usesValidCharacters = Predicate<String>
    .init { $0.contains(where: invalidCharacters.contains) }
    .negated()

let isValidUsername = hasValidLength && usesValidCharacters
```

`Predicate` instances can also be created using the static `all(of:)` and `any(of:)` methods:

```swift
let isOddPositiveMultipleOfThree: Predicate<Int> = 
    .all(of:
        { $0 % 2 != 0 },
        { $0 > 0 },
        { $0 % 3 == 0 }
    )
	
(-15...15).filter(isOddPositiveMultipleOfThree) // [3, 9, 15]
```

#### `Comparator`

The `Comparator` type is defined as

```swift
typealias Comparator<T> = Function<(T, T), Foundation.ComparisonResult>
```

`Comparator` instances are useful for comparing two values of the same type, particularly for sorting. They can be created in a variety of ways:

- A `Comparator` on a `Comparable` type can be created with the static `naturalOrder()` and `reverseOrder()` methods.
- A `Comparator` on a type can be created based on one of its `Comparable` properties with the static `comparing(by:)` method.
- A `Comparator` on a type can be created based on one of its `Optional` `Comparable` properties with the static `nilValuesFirst(by:)` and `nilValuesLast(by:)` methods.
	
Once created, `Comparator` instances can be:

- sequenced with the `thenComparing(by:)` method.
- reversed with the `reversed()` method.
- lifted to a `Comparator` on another type with the `lifting(with:)` method.

```swift
struct User {
    let id: Int
    let signupDate: Date
    let email: String?
}

// Compares `User` instances, where
// - emails are compared lexicographically, with `nil` values coming after non-`nil` values
// - ties (i.e. two emails are the same, or both are `nil`) are broken by comparing the users' ids, with the lower id coming first.
let userEmailThenId = Comparator<User>
    .nilValuesLast(by: { $0.email })
    .thenComparing(by: { $0.id })
	
let sortedUsers = users.sorted(by: userEmailThenId)
```

A `Comparator` on a type can be created from a sequence of `Comparator` instances on that type using the static `sequence` method.

```swift
// Compares `User` instances, where
// - users who signed up earlier come first
// - if users signed up at the exact same time, their emails are compared lexicographically
// - if users' emails are identical or both `nil`, the user with the lower id comes first
let userSignupDateThenEmailThenId: Comparator<User> =
    .sequence(
        .comparing(by: { $0.signupDate }),
        .nilValuesLast(by: { $0.email }),
        .comparing(by: { $0.id })
    )
```

### Inout Functions

Functions of type `(inout A) -> Void` can be modeled with `InoutFunction`, a separate type from `Function` that provides the ability to concatenate inout functions.

A `Function<A, A>` can be converted to an `InoutFunction<A>` with the `toInout()` method and back with the `withoutInout()` method:

```swift
let increment = Function { (x: Int) in x + 1 } // Function<Int, Int>
let inoutIncrement = increment.toInout()       // InoutFunction<Int>
var x = 1
inoutIncrement.apply(&x) // x == 2
inoutIncrement.apply(&x) // x == 3
```

### Throwing Functions

Throwing functions will be supported in an upcoming update—check back soon!

## Installation

### Carthage

Add the following line to your Cartfile:

`github "mpangburn/FunctionKit" ~> 0.1.0`

### CocoaPods

Add the following line to your Podfile:

`pod 'FunctionKit', '~> 0.1.0'`

### Swift Package Manager

Add the following line to your Package.swift file:

`.package(url: "https://github.com/mpangburn/FunctionKit", from: "0.1.0")`

## References

- [pointfreeco/Overture](https://github.com/pointfreeco/swift-overture)
- [pointfreeco/Prelude](https://github.com/pointfreeco/swift-prelude)
- [ceidhof](https://github.com/chriseidhof) on [Sort Descriptors](https://www.youtube.com/watch?v=ZFEwvJSZnQ0)
- [Java Functional Interface Reference](https://docs.oracle.com/javase/8/docs/api/java/util/function/package-summary.html)

## License

FunctionKit is released under the MIT license. See [LICENSE](https://github.com/mpangburn/FunctionKit/blob/master/LICENSE) for details.
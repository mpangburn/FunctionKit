//
//  InoutFunction.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/14/18.
//

/// A wrapper around a Swift `inout` function designed to provide functional operations
/// such as concatenation.
public class InoutFunction<Input> {
    /// The wrapped Swift function.
    private let _apply: (inout Input) -> Void

    /// Calls the function with the given input.
    /// - Parameter input: The input with which to call the function.
    /// - Note: Referencing this function as a member serves as a method to turn a `InoutFunction<Input>`
    ///         back into a Swift function of type `(inout Input) -> Void`.
    public func apply(_ input: inout Input) {
        _apply(&input)
    }

    /// Creates an `InoutFunction` from a Swift function.
    ///
    /// By promoting a Swift function to an `InoutFunction`, it gains access to functional operations
    /// such as concatenation.
    /// - Parameter f: The Swift function to promote.
    /// - Returns: The promoted function.
    public init(_ f: @escaping (inout Input) -> Void) {
        self._apply = f
    }
}

extension InoutFunction {
    /// Returns an inout-based setter function for the given key path.
    /// - Parameter keyPath: The key path for which to produce the setter function.
    /// - Returns: An inout-based setter function for the given key path.
    public static func update<Root>(_ keyPath: WritableKeyPath<Root, Input>) -> Function<InoutFunction<Input>, InoutFunction<Root>> {
        return .init { update in
            .init { root in
                update.apply(&root[keyPath: keyPath])
            }
        }
    }
}

// MARK: - Concatenation

extension InoutFunction {
    /// Returns a new function that applies this function followed by the given function.
    /// - Parameter other: The additional apply function to apply.
    /// - Returns: A new function that applies this function followed by the given function.
    public func concatenated(with other: InoutFunction<Input>) -> InoutFunction<Input> {
        return .concatenation(self, other)
    }

    /// Returns a new function that applies this function followed by the given function.
    /// - Parameter other: The additional apply function to apply.
    /// - Returns: A new function that applies this function followed by the given function.
    public func concatenated(with other: @escaping (inout Input) -> Void) -> InoutFunction<Input> {
        return .concatenation(apply, other)
    }

    /// Creates a function that applies the given functions in sequence.
    /// - Parameter functions: The functions to concatenate in sequence.
    /// - Parameter finally: An optional function as a convenience for trailing closure syntax.
    /// - Returns: A function concatenating the given functions.
    public static func concatenation(
        _ functions: InoutFunction<Input>...,
        and finally: @escaping (inout Input) -> Void = { _ in }
    ) -> InoutFunction<Input> {
        return .concatenation(functions.map { $0.apply }, and: finally)
    }

    /// Creates a function that applies the given functions in sequence.
    /// - Parameter functions: The functions to concatenate in sequence.
    /// - Parameter finally: An optional function as a convenience for trailing closure syntax.
    /// - Returns: A function concatenating the given functions.
    public static func concatenation(
        _ functions: (inout Input) -> Void...,
        and finally: @escaping (inout Input) -> Void = { _ in }
    ) -> InoutFunction<Input> {
        return .concatenation(functions, and: finally)
    }

    internal static func concatenation(
        _ functions: [(inout Input) -> Void],
        and finally: @escaping (inout Input) -> Void
    ) -> InoutFunction<Input> {
        return .init { input in
            functions.forEach { f in f(&input) }
            finally(&input)
        }
    }
}

// MARK: - Function Conversion

extension InoutFunction {
    /// Converts this function to its non-`inout` equivalent by creating a copy of the input and applying the apply.
    /// - Returns: This function converted to its non-`inout` equivalent.
    public func withoutInout() -> Function<Input, Input> {
        return .init { input in
            var input = input
            self.apply(&input)
            return input
        }
    }
}

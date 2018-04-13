//
//  Predicate.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/10/18.
//

/// A function that tests that its input fulfills certain criteria.
public typealias Predicate<Input> = Function<Input, Bool>

extension Function where Output == Bool {
    // MARK: Logical negation

    /// Returns a new predicate that negates the result of this predicate.
    /// - Returns: A new predicate that negates the result of this predicate.
    /// - Note: The prefix `!` operator can also be used to the effect of this function.
    public func negated() -> Predicate<Input> {
        return .init { input in
            !self.call(with: input)
        }
    }

    /// Returns a new predicate that negates the result of this predicate.
    /// - Returns: A new predicate that negates the result of this predicate.
    public static prefix func ! (predicate: Predicate<Input>) -> Predicate<Input> {
        return predicate.negated()
    }

    // MARK: - Logical conjunction

    /// Returns a new predicate that returns `true` only if the input passes the test of both predicates.
    /// - Parameter other: The other predicate to test.
    /// - Returns: A new predicate that returns `true` only if the input passes the test of both predicates.
    /// - Note: The infix `&&` operator can also be used to the effect of this function.
    public func and(_ other: Predicate<Input>) -> Predicate<Input> {
        return .init { input in
            self.call(with: input) && other.call(with: input)
        }
    }

    /// Returns a new predicate that returns `true` only if the input passes the test of both predicates.
    /// - Parameter other: The other predicate to test.
    /// - Returns: A new predicate that returns `true` only if the input passes the test of both predicates.
    public static func && (lhs: Predicate<Input>, rhs: Predicate<Input>) -> Predicate<Input> {
        return lhs.and(rhs)
    }

    // MARK: - Logical disjunction

    /// Returns a new predicate that returns `true` if the input passes the test of either predicate.
    /// - Parameter other: The other predicate to test.
    /// - Returns: A new predicate that returns `true` if the input passes the test of either predicate.
    /// - Note: The infix `||` operator can also be used to the effect of this function.
    public func or(_ other: Predicate<Input>) -> Predicate<Input> {
        return .init { input in
            self.call(with: input) || other.call(with: input)
        }
    }

    /// Returns a new predicate that returns `true` if the input passes the test of either predicate.
    /// - Parameter other: The other predicate to test.
    /// - Returns: A new predicate that returns `true` if the input passes the test of either predicate.
    public static func || (lhs: Predicate<Input>, rhs: Predicate<Input>) -> Predicate<Input> {
        return lhs.or(rhs)
    }
}

// MARK: - Utilities

extension Function where Input: Equatable, Output == Bool {
    /// Returns a predicate that returns `true` the input is equal to `input`.
    /// - Parameter input: The input against which the equality test is made.
    /// - Returns: A predicate that returns `true` the input is equal to `input`.
    public static func isEqual(to input: Input) -> Predicate<Input> {
        return .init { $0 == input }
    }

    /// Returns a predicate that returns `true` the input is not equal to `input`.
    /// - Parameter input: The input against which the equality test is made.
    /// - Returns: A predicate that returns `true` the input is not equal to `input`.
    public static func isNotEqual(to input: Input) -> Predicate<Input> {
        return .init { $0 != input }
    }
}

extension Function where Input: Comparable, Output == Bool {
    /// Returns a predicate that returns `true` the input is less than `input`.
    /// - Parameter input: The input against which the comparison test is made.
    /// - Returns: A predicate that returns `true` the input is less than `input`.
    public static func isLessThan(_ input: Input) -> Predicate<Input> {
        return .init { $0 < input }
    }

    /// Returns a predicate that returns `true` the input is less than or equal to `input`.
    /// - Parameter input: The input against which the comparison test is made.
    /// - Returns: A predicate that returns `true` the input is less than or equal to `input`.
    public static func isLessThanOrEqualTo(_ input: Input) -> Predicate<Input> {
        return .init { $0 <= input }
    }

    /// Returns a predicate that returns `true` the input is greater than `input`.
    /// - Parameter input: The input against which the comparison test is made.
    /// - Returns: A predicate that returns `true` the input is greater than `input`.
    public static func isGreaterThan(_ input: Input) -> Predicate<Input> {
        return .init { $0 > input }
    }

    /// Returns a predicate that returns `true` the input is greater than or equal to `input`.
    /// - Parameter input: The input against which the comparison test is made.
    /// - Returns: A predicate that returns `true` the input is greater than or equal to `input`.
    public static func isGreaterThanOrEqualTo(_ input: Input) -> Predicate<Input> {
        return .init { $0 >= input }
    }
}

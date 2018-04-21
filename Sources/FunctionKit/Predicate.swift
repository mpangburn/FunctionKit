//
//  Predicate.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/10/18.
//

/// A function that tests that its input fulfills certain criteria.
public typealias Predicate<Input> = Function<Input, Bool>

extension Function where Output == Bool {
    /// Evaluates the predicate with the given input.
    ///
    /// This function is an alias for `apply(_:)` for clarity of intent.
    /// - Parameter input: The input to test.
    /// - Returns: The evaluation of the predicate with the given input.
    public func test(_ input: Input) -> Bool {
        return apply(input)
    }

    // MARK: Logical Negation

    /// Returns a new predicate that negates the result of this predicate.
    /// - Returns: A new predicate that negates the result of this predicate.
    /// - Note: The prefix `!` operator can also be used to the effect of this function.
    public func negated() -> Predicate<Input> {
        return .init { input in
            !self.test(input)
        }
    }

    /// Returns a new predicate that negates the result of this predicate.
    /// - Returns: A new predicate that negates the result of this predicate.
    public static prefix func ! (predicate: Predicate<Input>) -> Predicate<Input> {
        return predicate.negated()
    }

    // MARK: - Logical Conjunction

    /// Creates a new predicate that returns `true` only when all of the given predicates return `true`.
    /// - Parameter predicates: The predicates to use in evaluating input.
    /// - Parameter finalPredicate: An optional final predicate as a convenience for trailing closure syntax.
    /// - Returns: A new predicate that returns `true` only when all of the given predicates return `true`.
    public static func all(
        of predicates: Predicate<Input>...,
        and finalPredicate: @escaping (Input) -> Bool = { _ in true }
    ) -> Predicate<Input> {
        return .all(of: predicates.map { $0.test }, and: finalPredicate)
    }

    /// Creates a new predicate that returns `true` only when all of the given predicates return `true`.
    /// - Parameter predicates: The predicates to use in evaluating input.
    /// - Parameter finalPredicate: An optional final predicate as a convenience for trailing closure syntax.
    /// - Returns: A new predicate that returns `true` only when all of the given predicates return `true`.
    public static func all(
        of predicates: (Input) -> Bool...,
        and finalPredicate: @escaping (Input) -> Bool = { _ in true }
    ) -> Predicate<Input> {
        return .all(of: predicates, and: finalPredicate)
    }

    internal static func all(
        of predicates: [(Input) -> Bool],
        and finalPredicate: @escaping (Input) -> Bool
        ) -> Predicate<Input> {
        return .init { input in
            for predicate in predicates {
                guard predicate(input) else {
                    return false
                }
            }
            return finalPredicate(input)
        }
    }

    /// Returns a new predicate that returns `true` only if the input passes the test of both predicates.
    /// - Parameter other: The other predicate to test.
    /// - Returns: A new predicate that returns `true` only if the input passes the test of both predicates.
    public static func && (lhs: Predicate<Input>, rhs: Predicate<Input>) -> Predicate<Input> {
        return .init { input in
            lhs.test(input) && rhs.test(input)
        }
    }

    // MARK: - Logical Disjunction

    /// Creates a new predicate that returns `true` when any of the given predicates returns `true`.
    /// - Parameter predicates: The predicates to use in evaluating input.
    /// - Parameter finalPredicate: An optional final predicate as a convenience for trailing closure syntax.
    /// - Returns: A new predicate that returns `true` when any of the given predicates returns `true`.
    public static func any(
        of predicates: Predicate<Input>...,
        or finalPredicate: @escaping (Input) -> Bool = { _ in false }
    ) -> Predicate<Input> {
        return .any(of: predicates.map { $0.test }, or: finalPredicate)
    }

    /// Creates a new predicate that returns `true` when any of the given predicates returns `true`.
    /// - Parameter predicates: The predicates to use in evaluating input.
    /// - Parameter finalPredicate: An optional final predicate as a convenience for trailing closure syntax.
    /// - Returns: A new predicate that returns `true` when any of the given predicates returns `true`.
    public static func any(
        of predicates: (Input) -> Bool...,
        or finalPredicate: @escaping (Input) -> Bool = { _ in false }
    ) -> Predicate<Input> {
        return .any(of: predicates, or: finalPredicate)
    }

    internal static func any(
        of predicates: [(Input) -> Bool],
        or finalPredicate: @escaping (Input) -> Bool
    ) -> Predicate<Input> {
        return .init { input in
            for predicate in predicates {
                if predicate(input) {
                    return true
                }
            }
            return finalPredicate(input)
        }
    }

    /// Returns a new predicate that returns `true` if the input passes the test of either predicate.
    /// - Parameter other: The other predicate to test.
    /// - Returns: A new predicate that returns `true` if the input passes the test of either predicate.
    public static func || (lhs: Predicate<Input>, rhs: Predicate<Input>) -> Predicate<Input> {
        return .init { input in
            lhs.test(input) || rhs.test(input)
        }
    }
}

// MARK: - Utilities

extension Function where Input: Equatable, Output == Bool {
    /// Returns a predicate that returns `true` the input is equal to `input`.
    /// - Parameter input: The input against which the equality test is made.
    /// - Returns: A predicate that returns `true` the input is equal to `input`.
    public static func isEqualTo(_ input: Input) -> Predicate<Input> {
        return .init { $0 == input }
    }

    /// Returns a predicate that returns `true` the input is not equal to `input`.
    /// - Parameter input: The input against which the equality test is made.
    /// - Returns: A predicate that returns `true` the input is not equal to `input`.
    public static func isNotEqualTo(_ input: Input) -> Predicate<Input> {
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

    /// Returns a predicate that returns `true` when the input lies in the given range.
    /// - Parameter range: The half-open range in which to check for containment.
    /// - Returns: A predicate that returns `true` when the input lies in the given range.
    public static func isInRange(_ range: Range<Input>) -> Predicate<Input> {
        return .init { range ~= $0 }
    }

    /// Returns a predicate that returns `true` when the input lies in the given range.
    /// - Parameter range: The closed range in which to check for containment.
    /// - Returns: A predicate that returns `true` when the input lies in the given range.
    public static func isInRange(_ range: ClosedRange<Input>) -> Predicate<Input> {
        return .init { range ~= $0 }
    }
}

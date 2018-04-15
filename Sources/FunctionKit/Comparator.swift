//
//  Comparator.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/13/18.
//

import Foundation

/// A function that compares two values of the same type.
public typealias Comparator<T> = Function<(T, T), ComparisonResult>

fileprivate extension Comparable {
    func compare(to other: Self) -> ComparisonResult {
        if self < other {
            return .orderedAscending
        } else if self > other {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }
}

// MARK: - Static Methods

extension Function where Output == ComparisonResult {
    /// Returns a comparator that compares `Comparable` instances in natural order.
    public static func naturalOrder<T: Comparable>() -> Comparator<T> where Input == (T, T) {
        return .init { lhs, rhs in
            lhs.compare(to: rhs)
        }
    }

    /// Returns a comparator that compares `Comparable` instances in reverse order.
    public static func reverseOrder<T: Comparable>() -> Comparator<T> where Input == (T, T) {
        return .init { lhs, rhs in
            rhs.compare(to: lhs)
        }
    }

    /// Returns a comparator that compares by extracting a `Comparable` value using the given function.
    /// - Parameter comparableExtractor: A function providing a `Comparable` value by which to compare.
    /// - Returns: A comparator that compares the values extracted using the given function.
    public static func comparing<T, Value: Comparable>(by comparableExtractor: Function<T, Value>) -> Comparator<T> where Input == (T, T) {
        return Comparator<Value>.naturalOrder()
            .composing(with: { (comparableExtractor.call(with: $0), comparableExtractor.call(with: $1)) })
    }

    /// Returns a comparator that compares by extracting a `Comparable` value using the given function.
    /// - Parameter comparableExtractor: A function providing a `Comparable` value by which to compare.
    /// - Returns: A comparator that compares the values extracted using the given function.
    public static func comparing<T, Value: Comparable>(by comparableExtractor: @escaping (T) -> Value) -> Comparator<T> where Input == (T, T) {
        return comparing(by: .init(comparableExtractor))
    }
}

// MARK: - Comparator Sequencing

extension Function where Output == ComparisonResult {
    /// Creates a comparator by sequencing the given comparators
    /// where the next comparator in sequence is used if the operands are ordered the same by the previous.
    ///
    /// As soon as a comparator in the sequence determines that the operands are not ordered the same,
    /// its result is returned.
    /// - Parameter comparators: The comparators to sequence.
    /// - Parameter finalComparator: An optional final comparator as a convenience for trailing closure syntax.
    /// - Returns: A comparator created by sequencing the given comparators.
    public static func sequence<T>(_
        comparators: Comparator<T>...,
        and finalComparator: @escaping (T, T) -> ComparisonResult = { _, _ in .orderedSame}
    ) -> Comparator<T> where Input == (T, T) {
        return .init { lhs, rhs in
            for comparator in comparators {
                let result = comparator.compare(lhs, rhs)
                if result != .orderedSame {
                    return result
                }
            }
            return finalComparator(lhs, rhs)
        }
    }
}

// MARK: - Instance Methods

extension Function where Output == ComparisonResult {
    /// Compares the two arguments for order.
    /// - Parameter lhs: The left argument to compare.
    /// - Parameter rhs: The right argument to compare.
    /// - Returns: The result of the comparison.
    public func compare<T>(_ lhs: T, _ rhs: T) -> ComparisonResult where Input == (T, T) {
        return call(with: (lhs, rhs))
    }

    /// Returns a new comparator that first compares using this comparator, then by the given comparator in the case where operands are ordered the same.
    /// - Parameter nextComparator: The comparator to use to compare in the case where this comparator determines the operands are ordered the same.
    /// - Returns: A new comparator using the given comparator to secondarily compare.
    public func thenComparing<T>(by nextComparator: Comparator<T>) -> Comparator<T> where Input == (T, T) {
        return .sequence(self, nextComparator)
    }

    /// Returns a new comparator that first compares using this comparator, then by the value extracted
    /// using the given function in the case where operands are ordered the same.
    /// - Parameter comparableExtractor: The function to extract the value to compare by
    ///                                  in the case where this comparator determines the operands are ordered the same.
    /// - Returns: A new comparator using the given value extractor to secondarily compare.
    public func thenComparing<T, Value: Comparable>(by comparableExtractor: Function<T, Value>) -> Comparator<T> where Input == (T, T) {
        return .sequence(self, .comparing(by: comparableExtractor))
    }

    /// Returns a new comparator that first compares using this comparator, then by the value extracted
    /// using the given function in the case where operands are ordered the same.
    /// - Parameter comparableExtractor: The function to extract the value to compare by
    ///                                  in the case where this comparator determines the operands are ordered the same.
    /// - Returns: A new comparator using the given value extractor to secondarily compare.
    public func thenComparing<T, Value: Comparable>(by comparableExtractor: @escaping (T) -> Value) -> Comparator<T> where Input == (T, T) {
        return .sequence(self, .comparing(by: comparableExtractor))
    }

    /// Returns a comparator that imposes the reverse ordering of this comparator.
    public func reversed<T>() -> Comparator<T> where Input == (T, T) {
        return .init { lhs, rhs in
            switch self.compare(lhs, rhs) {
            case .orderedAscending:
                return .orderedDescending
            case .orderedSame:
                return .orderedSame
            case .orderedDescending:
                return .orderedAscending
            }
        }
    }
}

// MARK: - Optional Compatibility

extension Function where Output == ComparisonResult {
    /// Returns an optional-friendly comparator that orders `nil` values before non-`nil` values.
    public static func nilValuesFirst<T: Comparable>() -> Comparator<T?> where Input == (T?, T?) {
        return .nilValuesFirst(by: .naturalOrder())
    }

    /// Returns an optional-friendly comparator that orders `nil` values before non-`nil` values.
    /// - Parameter comparator: The comparator to use in cases where both values are non-`nil`.
    /// - Returns: An optional-friendly comparator that orders `nil` values before non-`nil` values.
    public static func nilValuesFirst<T>(by comparator: Comparator<T>) -> Comparator<T?> where Input == (T?, T?) {
        return .init { lhs, rhs in
            switch (lhs, rhs) {
            case (nil, nil):
                return .orderedSame
            case (nil, _):
                return .orderedAscending
            case (_, nil):
                return .orderedDescending
            case (let lhs?, let rhs?):
                return comparator.compare(lhs, rhs)
            }
        }
    }

    /// Returns an optional-friendly comparator that compares by extracting a an optional `Comparable` key using the given function,
    /// ordering `nil` values before non-`nil` values.
    /// - Parameter optionalComparableExtractor: A function providing an optional `Comparable` value by which to compare.
    /// - Returns: A comparator that compares the values extracted using the given function, ordering `nil` values before non-`nil` values.
    public static func nilValuesFirst<T, Value: Comparable>(by optionalComparableExtractor: Function<T, Value?>) -> Comparator<T> where Input == (T, T) {
        return Comparator<Value?>.nilValuesFirst()
            .composing(with: { (optionalComparableExtractor.call(with: $0), optionalComparableExtractor.call(with: $1)) })
    }

    /// Returns an optional-friendly comparator that compares by extracting a an optional `Comparable` key using the given function,
    /// ordering `nil` values before non-`nil` values.
    /// - Parameter optionalComparableExtractor: A function providing an optional `Comparable` value by which to compare.
    /// - Returns: A comparator that compares the values extracted using the given function, ordering `nil` values before non-`nil` values.
    public static func nilValuesFirst<T, Value: Comparable>(by optionalComparableExtractor: @escaping (T) -> Value?) -> Comparator<T> where Input == (T, T) {
        return .nilValuesFirst(by: .init(optionalComparableExtractor))
    }

    /// Returns an optional-friendly comparator that orders `nil` values after non-`nil` values.
    public static func nilValuesLast<T: Comparable>() -> Comparator<T?> where Input == (T?, T?) {
        return .nilValuesLast(by: .naturalOrder())
    }

    /// Returns an optional-friendly comparator that orders `nil` values after non-`nil` values.
    /// - Parameter comparator: The comparator to use in cases where both values are non-`nil`.
    /// - Returns: An optional-friendly comparator that orders `nil` values after non-`nil` values.
    public static func nilValuesLast<T>(by comparator: Comparator<T>) -> Comparator<T?> where Input == (T?, T?) {
        return .init { lhs, rhs in
            switch (lhs, rhs) {
            case (nil, nil):
                return .orderedSame
            case (nil, _):
                return .orderedDescending
            case (_, nil):
                return .orderedAscending
            case (let lhs?, let rhs?):
                return comparator.compare(lhs, rhs)
            }
        }
    }

    /// Returns an optional-friendly comparator that compares by extracting a an optional `Comparable` key using the given function,
    /// ordering `nil` values after non-`nil` values.
    /// - Parameter optionalComparableExtractor: A function providing an optional `Comparable` value by which to compare.
    /// - Returns: A comparator that compares the values extracted using the given function, ordering `nil` values after non-`nil` values.
    public static func nilValuesLast<T, Value: Comparable>(by optionalComparableExtractor: Function<T, Value?>) -> Comparator<T> where Input == (T, T) {
        return Comparator<Value?>.nilValuesLast()
            .composing(with: { (optionalComparableExtractor.call(with: $0), optionalComparableExtractor.call(with: $1)) })
    }

    /// Returns an optional-friendly comparator that compares by extracting a an optional `Comparable` key using the given function,
    /// ordering `nil` values after non-`nil` values.
    /// - Parameter optionalComparableExtractor: A function providing an optional `Comparable` value by which to compare.
    /// - Returns: A comparator that compares the values extracted using the given function, ordering `nil` values after non-`nil` values.
    public static func nilValuesLast<T, Value: Comparable>(by optionalComparableExtractor: @escaping (T) -> Value?) -> Comparator<T> where Input == (T, T) {
        return .nilValuesLast(by: .init(optionalComparableExtractor))
    }
}

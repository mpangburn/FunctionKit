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

extension Function where Output == ComparisonResult {
    /// Compares the two arguments for order.
    /// - Parameter lhs: The left argument to compare.
    /// - Parameter rhs: The right argument to compare.
    /// - Returns: The result of the comparison.
    public func compare<T>(_ lhs: T, _ rhs: T) -> ComparisonResult where Input == (T, T) {
        return call(with: (lhs, rhs))
    }

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

    /// Returns a comparator that compares by extracting a `Comparable` key using the given function.
    /// - Parameter comparableProvider: A function providing a `Comparable` value by which to compare.
    /// - Returns: A comparator that compares the values extracted using the given function.
    public static func comparing<T, Value: Comparable>(by comparableProvider: Function<T, Value>) -> Comparator<T> where Input == (T, T) {
        return Comparator<Value>.naturalOrder().composing { (comparableProvider.call(with: $0), comparableProvider.call(with: $1)) }
    }

    /// Returns a comparator that compares by extracting a `Comparable` key using the given function.
    /// - Parameter comparableProvider: A function providing a `Comparable` value by which to compare.
    /// - Returns: A comparator that compares the values extracted using the given function.
    public static func comparing<T, Value: Comparable>(by comparableProvider: @escaping (T) -> Value) -> Comparator<T> where Input == (T, T) {
        return comparing(by: .init(comparableProvider))
    }

    /// Returns a new comparator that first compares using this comparator, then by the given comparator in the case where operands are ordered the same.
    /// - Parameter nextComparator: The comparator to use to compare in the case where this comparator determines the operands are ordered the same.
    /// - Returns: A new comparator using the given comparator to secondarily compare.
    public func thenComparing<T>(by nextComparator: Comparator<T>) -> Comparator<T> where Input == (T, T) {
        return .init { lhs, rhs in
            let primaryResult = self.compare(lhs, rhs)
            if primaryResult == .orderedSame {
                return nextComparator.compare(lhs, rhs)
            } else {
                return primaryResult
            }
        }
    }

    /// Returns a new comparator that first compares using this comparator, then by the given comparator in the case where operands are ordered the same.
    /// - Parameter nextComparator: The comparator to use to compare in the case where this comparator determines the operands are ordered the same.
    /// - Returns: A new comparator using the given comparator to secondarily compare.
    public func thenComparing<T, Value: Comparable>(by comparableProvider: Function<T, Value>) -> Comparator<T> where Input == (T, T) {
        return thenComparing(by: .comparing(by: comparableProvider))
    }

    /// Returns a new comparator that first compares using this comparator, then by the given comparator in the case where operands are ordered the same.
    /// - Parameter nextComparator: The comparator to use to compare in the case where this comparator determines the operands are ordered the same.
    /// - Returns: A new comparator using the given comparator to secondarily compare.
    public func thenComparing<T, Value: Comparable>(by comparableProvider: @escaping (T) -> Value) -> Comparator<T> where Input == (T, T) {
        return thenComparing(by: .comparing(by: comparableProvider))
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

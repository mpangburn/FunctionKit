//
//  Sequence.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/10/18.
//

extension Sequence {
    public func map<T>(_ transform: Function<Element, T>) -> [T] {
        return map(transform.apply)
    }

    public func flatMap<SegmentOfResult: Sequence>(_ transform: Function<Element, SegmentOfResult>) -> [SegmentOfResult.Element] {
        return flatMap(transform.apply)
    }

    public func compactMap<T>(_ transform: Function<Element, T?>) -> [T] {
        return compactMap(transform.apply)
    }

    public func filter(_ predicate: Predicate<Element>) -> [Element] {
        return filter(predicate.apply)
    }

    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: Function<(Result, Element), Result>) -> Result {
        // if we don't declare f as a separate variable, we get a compile-time error here
        // TODO: reproduce and file a bug report
        let f = nextPartialResult.apply
        return reduce(initialResult, f)
    }

    public func sorted(by comparator: Comparator<Element>) -> [Element] {
        return sorted { comparator.compare($0, $1) == .orderedAscending }
    }
}

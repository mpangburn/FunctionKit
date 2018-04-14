//
//  MutableCollection.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/13/18.
//

extension MutableCollection where Self: RandomAccessCollection {
    public mutating func sort(by comparator: Comparator<Element>) {
        sort { lhs, rhs in
            comparator.compare(lhs, rhs) == .orderedAscending
        }
    }
}

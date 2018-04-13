//
//  Optional.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/10/18.
//

extension Optional {
    public func map<T>(_ transform: Function<Wrapped, T>) -> T? {
        return map(transform.call)
    }

    public func flatMap<T>(_ transform: Function<Wrapped, T?>) -> T? {
        return flatMap(transform.call)
    }
}

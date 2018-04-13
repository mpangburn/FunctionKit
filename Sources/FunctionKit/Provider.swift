//
//  Provider.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/10/18.
//

/// A function that takes no input and produces output.
public typealias Provider<Output> = Function<Void, Output>

extension Function where Input == Void {
    /// Invokes the supplier function and returns the output.
    /// - Returns: The output produced by the supplier function.
    public func make() -> Output {
        return call(with: ())
    }
}

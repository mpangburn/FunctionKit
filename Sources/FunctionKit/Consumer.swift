//
//  Consumer.swift
//  FunctionKit
//
//  Created by Michael Pangburn on 4/10/18.
//

/// A function that takes input and produces no output.
public typealias Consumer<Input> = Function<Input, Void>

extension Function where Output == Void {
    /// Returns a new consumer that performs, in sequence, this operation followed by the given operation.
    /// - Parameter next: The operation to perform with the input after this operation is performed.
    /// - Returns: A new consumer that performs, in sequence, this operation followed by the given operation.
    public func then(_ next: Consumer<Input>) -> Consumer<Input> {
        return then(next.apply)
    }

    /// Returns a new consumer that performs, in sequence, this operation followed by the given operation.
    /// - Parameter next: The operation to perform with the input after this operation is performed.
    /// - Returns: A new consumer that performs, in sequence, this operation followed by the given operation.
    public func then(_ next: @escaping (Input) -> Void) -> Consumer<Input> {
        return .init { input in
            self.apply(input)
            next(input)
        }
    }
}

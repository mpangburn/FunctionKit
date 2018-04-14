//
//  InoutFunctionTests.swift
//  FunctionKitTests
//
//  Created by Michael Pangburn on 4/14/18.
//

import XCTest
@testable import FunctionKit


private let increment: (inout Int) -> Void = { $0 += 1 }
private let square: (inout Int) -> Void = { $0 *= $0 }

class InoutFunctionTests: XCTestCase {
    func testConcat() {
        let incrementAndSquares = [
            InoutFunction(increment).concatenating(with: square),
            InoutFunction(increment).concatenating(with: .init(square)),
            InoutFunction.concatenation(increment, square),
            InoutFunction.concatenation(.init(increment), .init(square))
        ]
        for incrementAndSquare in incrementAndSquares {
            var numbers = [1, 2, 3]
            for index in numbers.indices {
                incrementAndSquare.update(&numbers[index])
            }
            XCTAssertEqual(numbers, [4, 9, 16])
        }

        let incrementSixTimes = InoutFunction.concatenation(increment, increment, increment, increment, increment, increment)
        var x = 0
        incrementSixTimes.update(&x)
        XCTAssertEqual(x, 6)
    }

    func testWithoutInout() {
        let nonInoutIncrement = InoutFunction(increment).withoutInout()
        let x = 0
        XCTAssertEqual(nonInoutIncrement.call(with: x), 1)
        XCTAssertEqual(nonInoutIncrement.call(with: x), 1)
    }
}

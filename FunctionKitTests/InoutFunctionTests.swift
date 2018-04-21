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
            InoutFunction(increment).concatenated(with: square),
            InoutFunction(increment).concatenated(with: .init(square)),
            InoutFunction.concatenation(increment, square),
            InoutFunction.concatenation(.init(increment), .init(square))
        ]
        for incrementAndSquare in incrementAndSquares {
            var numbers = [1, 2, 3]
            for index in numbers.indices {
                incrementAndSquare.apply(&numbers[index])
            }
            XCTAssertEqual(numbers, [4, 9, 16])
        }

        let incrementSixTimes = InoutFunction.concatenation(increment, increment, increment, increment, increment, increment)
        var x = 0
        incrementSixTimes.apply(&x)
        XCTAssertEqual(x, 6)
    }

    func testUpdate() {
        struct Person { var name: String }
        let updateName = InoutFunction.update(\Person.name)
        let lowercasename = updateName.apply { $0 = $0.lowercased() }
        var michael = Person(name: "MICHAEL")
        lowercasename.apply(&michael)
        XCTAssert(michael.name == "michael")
    }

    func testWithoutInout() {
        let nonInoutIncrement = InoutFunction(increment).withoutInout()
        let x = 0
        XCTAssertEqual(nonInoutIncrement.apply(x), 1)
        XCTAssertEqual(nonInoutIncrement.apply(x), 1)
    }
}

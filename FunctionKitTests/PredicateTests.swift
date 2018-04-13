//
//  PredicateTests.swift
//  FunctionKitTests
//
//  Created by Michael Pangburn on 4/10/18.
//

import XCTest
@testable import FunctionKit


class PredicateTests: XCTestCase {
    func isEven(_ x: Int) -> Bool {
        return x % 2 == 0
    }

    func isPositive(_ x: Int) -> Bool {
        return x > 0
    }

    func testNot() {
        let numbers = -5...5
        let isNegativeOrZero = !Predicate(isPositive)
        let negativeOrZeroNumbers = numbers.filter(isNegativeOrZero)
        XCTAssertEqual(negativeOrZeroNumbers, [-5, -4, -3, -2, -1, 0])
    }

    func testAnd() {
        let numbers = -5...5
        let isEvenAndPositive = Predicate(isEven) && Predicate(isPositive)
        let evenPositiveNumbers = numbers.filter(isEvenAndPositive)
        XCTAssertEqual(evenPositiveNumbers, [2, 4])
    }

    func testOr() {
        let numbers = -5...5
        let isEvenOrPositive = Predicate(isEven) || Predicate(isPositive)
        let evenOrPositiveNumbers = numbers.filter(isEvenOrPositive)
        XCTAssertEqual(evenOrPositiveNumbers, [-4, -2, 0, 1, 2, 3, 4, 5])
    }

    func testEquals() {
        let numbers = [1, 2, 3, 3, 3, 4, 5]
        let justThrees = numbers.filter(.isEqual(to: 3))
        XCTAssertEqual(justThrees, [3, 3, 3])

        let notThrees = numbers.filter(.isNotEqual(to: 3))
        XCTAssertEqual(notThrees, [1, 2, 4, 5])
    }

    func testComparison() {
        let numbers = 0...5
        let lessThan3 = numbers.filter(.isLessThan(3))
        XCTAssertEqual(lessThan3, [0, 1, 2])

        let lessThanOrEqualTo3 = numbers.filter(.isLessThanOrEqualTo(3))
        XCTAssertEqual(lessThanOrEqualTo3, [0, 1, 2, 3])

        let greaterThan3 = numbers.filter(.isGreaterThan(3))
        XCTAssertEqual(greaterThan3, [4, 5])

        let greaterThanOrEqualTo3 = numbers.filter(.isGreaterThanOrEqualTo(3))
        XCTAssertEqual(greaterThanOrEqualTo3, [3, 4, 5])
    }
}

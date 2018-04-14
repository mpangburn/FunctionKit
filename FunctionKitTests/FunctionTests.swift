//
//  FunctionTests.swift
//  FunctionTests
//
//  Created by Michael Pangburn on 4/9/18.
//

import XCTest
@testable import FunctionKit


private let increment: (Int) -> Int = { $0 + 1 }
private let square: (Int) -> Int = { $0 * $0 }
private let some: (Int) -> Int? = { .some($0) }
private let none: (Int) -> Int? = { _ in .none }
private let funcInFuncOut: (@escaping (Int) -> Int) -> (Int) -> Int = { $0 }

class FunctionTests: XCTestCase {
    func testCall() {
        let fooHasPrefix = "foo".hasPrefix
        XCTAssert(fooHasPrefix("fo"))
        XCTAssert(Function(fooHasPrefix).call(with: "fo"))
    }

    func testIdentity() {
        let identity: Function<Int, Int> = .identity()
        for integer in [.min, -42, -1, 0, 1, 42, .max] {
            XCTAssertEqual(identity.call(with: integer), integer)
        }
    }

    func testConstant() {
        let numbers = 1...5
        let allTens = numbers.map(.constant(10))
        let expected = repeatElement(10, count: numbers.count)
        XCTAssert(allTens.elementsEqual(expected))
    }

    func testKeyPath() {
        let getCount: Function<[String], Int> = .get(\.count)
        XCTAssertEqual(getCount.call(with: []), 0)
        XCTAssertEqual(getCount.call(with: ["a", "b", "c"]), 3)
        XCTAssertEqual(getCount.call(with: ["a", "b", "c", "d", "e"]), 5)
    }

    func testPipe() {
        let numbers = 1...3

        let incrementAndSquares = [
            Function(increment).piping(into: square),
            Function(increment).piping { square($0) },
            Function(increment).piping(into: .init(square)),
            Function.pipeline(increment, square),
            Function.pipeline(.init(increment), .init(square))
        ]
        for incrementAndSquare in incrementAndSquares {
            XCTAssertEqual(numbers.map(incrementAndSquare), [4, 9, 16])
        }

        let incrementSquareAndStringify = Function.pipeline(increment, square, String.init)
        XCTAssertEqual(numbers.map(incrementSquareAndStringify), ["4", "9", "16"])

        let incrementSquareStringifyAndBack = Function.pipeline(increment, square, String.init, Int.init)
        XCTAssertEqual(numbers.map(incrementSquareStringifyAndBack), [4, 9, 16].map(Optional.some))

        let incrementFiveTimes = Function.pipeline(increment, increment, increment, increment, increment)
        XCTAssertEqual(numbers.map(incrementFiveTimes), [6, 7, 8])

        let incrementSixTimes = Function.pipeline(increment, increment, increment, increment, increment, increment)
        XCTAssertEqual(numbers.map(incrementSixTimes), [7, 8, 9])
    }

    func testConcat() {
        let numbers = 1...3

        let incrementAndSquares = [
            Function(increment).concatenating(with: square),
            Function.concatenation(increment, square),
            Function.concatenation(Function(increment), Function(square))
        ]
        for incrementAndSquare in incrementAndSquares {
            XCTAssertEqual(numbers.map(incrementAndSquare), [4, 9, 16])
        }

        let toTheEighthPowers = [
            Function(square).concatenating { square(square($0)) },
            Function.concatenation(square, square, square),
            Function.concatenation(square, square) { square($0) }
        ]
        for totheEighthPower in toTheEighthPowers {
            XCTAssertEqual(numbers.map(totheEighthPower), [1, 256, 6561])
        }
    }

    func testChainWithTypeConversion() {
        let indexOfThumbsUpFromDataAndEncoding = Function(String.init(data:encoding:)).chaining(with: { $0.index(of: "👍") })
        let hasThumbsUp = "two thumbs up 👍👍 for this café"
        let hasThumbsUpData = hasThumbsUp.data(using: .utf8)!
        let doesNotHaveThumbsUpData = "👎".data(using: .utf8)!
        XCTAssertEqual(indexOfThumbsUpFromDataAndEncoding.call(with: (hasThumbsUpData, .utf8)), hasThumbsUp.index(of: "👍"))
        XCTAssertNil(String(data: hasThumbsUpData.dropLast(), encoding: .utf8))
        XCTAssertNil(indexOfThumbsUpFromDataAndEncoding.call(with: (hasThumbsUpData.dropLast(), .utf8)))
        XCTAssertNil(indexOfThumbsUpFromDataAndEncoding.call(with: (doesNotHaveThumbsUpData, .utf8)))
    }

    func testSuccessfulChains() {
        XCTAssertEqual(Function.chain(some, some).call(with: 5), .some(5))
        XCTAssertEqual(Function.chain(some, some, some).call(with: 5), .some(5))
        XCTAssertEqual(Function.chain(some, some, some, some).call(with: 5), .some(5))
        XCTAssertEqual(Function.chain(some, some, some, some, some).call(with: 5), .some(5))
        XCTAssertEqual(Function.chain(some, some, some, some, some, some).call(with: 5), .some(5))
    }

    func testFailingChains() {
        XCTAssertNil(Function.chain(none, some).call(with: 5))
        XCTAssertNil(Function.chain(some, none).call(with: 5))
        XCTAssertNil(Function.chain(none, none).call(with: 5))
        XCTAssertNil(Function.chain(some, none, some).call(with: 5))
        XCTAssertNil(Function.chain(some, some, some, none).call(with: 5))
        XCTAssertNil(Function.chain(none, some, some, some, some).call(with: 5))
        XCTAssertNil(Function.chain(some, none, none, none, some, some).call(with: 5))
    }

    func testCompose() {
        let numbers = 1...3

        let incrementAndSquares = [
            Function(square).composing(with: increment),
            Function(square).composing { increment($0) },
            Function(square).composing(with: Function(increment)),
            Function.composition(square, increment),
            Function.composition(Function(square), Function(increment))
        ]
        for incrementAndSquare in incrementAndSquares {
            XCTAssertEqual(numbers.map(incrementAndSquare), [4, 9, 16])
        }

        let incrementSquareAndStringify = Function.composition(String.init, square, increment)
        XCTAssertEqual(numbers.map(incrementSquareAndStringify), ["4", "9", "16"])

        let incrementSquareStringifyAndBack = Function.composition(Int.init, String.init, square, increment)
        XCTAssertEqual(numbers.map(incrementSquareStringifyAndBack), [4, 9, 16].map(Optional.some))

        let incrementFiveTimes = Function.composition(increment, increment, increment, increment, increment)
        XCTAssertEqual(numbers.map(incrementFiveTimes), [6, 7, 8])

        let incrementSixTimes = Function.composition(increment, increment, increment, increment, increment, increment)
        XCTAssertEqual(numbers.map(incrementSixTimes), [7, 8, 9])
    }

    func testCurry() {
        let stringFromDataAndEncoding = Function(String.init(data:encoding:)).curried()
        let string = "turn me into data! 👍"
        let data = string.data(using: .utf8)!
        let stringFromEncoding = stringFromDataAndEncoding.call(with: data)
        XCTAssertNotEqual(stringFromEncoding.call(with: .ascii), string)
        XCTAssertEqual(stringFromEncoding.call(with: .utf8), string)
    }

    func testUncurry() {
        let uncurriedHasPrefixes = [
            Function(String.hasPrefix).uncurried(),
            Function(String.hasPrefix).promotingOutput().uncurried()
        ]
        for uncurriedHasPrefix in uncurriedHasPrefixes {
            XCTAssert(uncurriedHasPrefix.call(with: ("string", "str")))
        }
    }

    func testFlipWithCurry() {
        let utf8StringFromData =
            Function(String.init(data:encoding:))
                .curried()
                .flippingFirstTwoArguments()
                .call(with: .utf8)
        let string = "turn me into data! 👍"
        let data = string.data(using: .utf8)!
        XCTAssertEqual(utf8StringFromData.call(with: data), string)
    }

    func testFlipWithoutCurry() {
        let stringStartsWithFoo =
            Function(String.hasPrefix)
                .flippingFirstTwoArguments()
                .call(with: "foo")
        XCTAssertTrue(stringStartsWithFoo.call(with: "foobinacci"))
        XCTAssertFalse(stringStartsWithFoo.call(with: "nope"))
    }

    func testPromotion() {
        let _: Function<Function<Int, Int>, Function<Int, Int>> = Function(funcInFuncOut).promotingInput().promotingOutput()
    }

    func testToInout() {
        let inoutIncrement = Function(increment).toInout()
        var x = 0
        inoutIncrement.update(&x)
        XCTAssertEqual(x, 1)
        inoutIncrement.update(&x)
        inoutIncrement.update(&x)
        XCTAssertEqual(x, 3)
    }
}

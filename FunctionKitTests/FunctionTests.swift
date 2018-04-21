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
    func testApply() {
        let fooHasPrefix = "foo".hasPrefix
        XCTAssert(fooHasPrefix("fo"))
        XCTAssert(Function(fooHasPrefix).apply("fo"))
    }

    func testIdentity() {
        let identity: Function<Int, Int> = .identity()
        for integer in [.min, -42, -1, 0, 1, 42, .max] {
            XCTAssertEqual(identity.apply(integer), integer)
        }
    }

    func testConstant() {
        let numbers = 1...5
        let allTens = numbers.map(.constant(10))
        let expected = repeatElement(10, count: numbers.count)
        XCTAssert(allTens.elementsEqual(expected))
    }

    func testKeyPathGet() {
        let getCount = Function.get(\String.count)
        XCTAssertEqual(getCount.apply(""), 0)
        XCTAssertEqual(getCount.apply("abc"), 3)
        XCTAssertEqual(getCount.apply("abcde"), 5)
    }

    func testKeyPathUpdate() {
        struct Person { var firstName: String }
        let updateFirstName = Function.update(\Person.firstName)
        let lowercaseFirstName = updateFirstName.apply { $0.lowercased() }
        let michael = Person(firstName: "Michael")
        let lauren = Person(firstName: "Lauren")
        XCTAssertEqual(lowercaseFirstName.apply(michael).firstName, "michael")
        XCTAssertEqual(lowercaseFirstName.apply(lauren).firstName, "lauren")

        class PersonReference { var firstName: String; init(firstName: String) { self.firstName = firstName } }
        let updateFirstNameReference = Function.update(\PersonReference.firstName)
        let lowercaseFirstNameReference = updateFirstNameReference.apply { $0.lowercased() }
        let miguel = PersonReference(firstName: "Miguel")
        _ = lowercaseFirstNameReference.apply(miguel)
        XCTAssertEqual(miguel.firstName, "miguel")
    }

    func testPipe() {
        let numbers = 1...3

        let incrementAndSquares = [
            Function(increment).piped(into: square),
            Function(increment).piped { square($0) },
            Function(increment).piped(into: .init(square)),
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
            Function(increment).concatenated(with: square),
            Function.concatenation(increment, square),
            Function.concatenation(Function(increment), Function(square))
        ]
        for incrementAndSquare in incrementAndSquares {
            XCTAssertEqual(numbers.map(incrementAndSquare), [4, 9, 16])
        }

        let toTheEighthPowers = [
            Function(square).concatenated { square(square($0)) },
            Function.concatenation(square, square, square),
            Function.concatenation(square, square) { square($0) }
        ]
        for totheEighthPower in toTheEighthPowers {
            XCTAssertEqual(numbers.map(totheEighthPower), [1, 256, 6561])
        }
    }

    func testChainWithTypeConversion() {
        let indexOfThumbsUpFromDataAndEncoding = Function(String.init(data:encoding:)).chained(with: { $0.index(of: "👍") })
        let hasThumbsUp = "two thumbs up 👍👍 for this café"
        let hasThumbsUpData = hasThumbsUp.data(using: .utf8)!
        let doesNotHaveThumbsUpData = "👎".data(using: .utf8)!
        XCTAssertEqual(indexOfThumbsUpFromDataAndEncoding.apply((hasThumbsUpData, .utf8)), hasThumbsUp.index(of: "👍"))
        XCTAssertNil(String(data: hasThumbsUpData.dropLast(), encoding: .utf8))
        XCTAssertNil(indexOfThumbsUpFromDataAndEncoding.apply((hasThumbsUpData.dropLast(), .utf8)))
        XCTAssertNil(indexOfThumbsUpFromDataAndEncoding.apply((doesNotHaveThumbsUpData, .utf8)))
    }

    func testSuccessfulChains() {
        XCTAssertEqual(Function.chain(some, some).apply(5), .some(5))
        XCTAssertEqual(Function.chain(some, some, some).apply(5), .some(5))
        XCTAssertEqual(Function.chain(some, some, some, some).apply(5), .some(5))
        XCTAssertEqual(Function.chain(some, some, some, some, some).apply(5), .some(5))
        XCTAssertEqual(Function.chain(some, some, some, some, some, some).apply(5), .some(5))
    }

    func testFailingChains() {
        XCTAssertNil(Function.chain(none, some).apply(5))
        XCTAssertNil(Function.chain(some, none).apply(5))
        XCTAssertNil(Function.chain(none, none).apply(5))
        XCTAssertNil(Function.chain(some, none, some).apply(5))
        XCTAssertNil(Function.chain(some, some, some, none).apply(5))
        XCTAssertNil(Function.chain(none, some, some, some, some).apply(5))
        XCTAssertNil(Function.chain(some, none, none, none, some, some).apply(5))
    }

    func testCompose() {
        let numbers = 1...3

        let incrementAndSquares = [
            Function(square).composed(with: increment),
            Function(square).composed { increment($0) },
            Function(square).composed(with: Function(increment)),
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
        let stringFromEncoding = stringFromDataAndEncoding.apply(data)
        XCTAssertNotEqual(stringFromEncoding.apply(.ascii), string)
        XCTAssertEqual(stringFromEncoding.apply(.utf8), string)
    }

    func testUncurry() {
        let uncurriedHasPrefixes = [
            Function(String.hasPrefix).uncurried(),
            Function(String.hasPrefix).promotingOutput().uncurried()
        ]
        for uncurriedHasPrefix in uncurriedHasPrefixes {
            XCTAssert(uncurriedHasPrefix.apply(("string", "str")))
        }
    }

    func testFlipWithCurry() {
        let utf8StringFromData =
            Function(String.init(data:encoding:))
                .curried()
                .flippingFirstTwoArguments()
                .apply(.utf8)
        let string = "turn me into data! 👍"
        let data = string.data(using: .utf8)!
        XCTAssertEqual(utf8StringFromData.apply(data), string)
    }

    func testFlipWithoutCurry() {
        let stringStartsWithFoo =
            Function(String.hasPrefix)
                .flippingFirstTwoArguments()
                .apply("foo")
        XCTAssertTrue(stringStartsWithFoo.apply("foobinacci"))
        XCTAssertFalse(stringStartsWithFoo.apply("nope"))
    }

    func testPromotion() {
        let _: Function<Function<Int, Int>, Function<Int, Int>> = Function(funcInFuncOut).promotingInput().promotingOutput()
    }

    func testToInout() {
        let inoutIncrement = Function(increment).toInout()
        var x = 0
        inoutIncrement.apply(&x)
        XCTAssertEqual(x, 1)
        inoutIncrement.apply(&x)
        inoutIncrement.apply(&x)
        XCTAssertEqual(x, 3)
    }
}

//
//  ConsumerTests.swift
//  FunctionKitTests
//
//  Created by Michael Pangburn on 4/11/18.
//

import XCTest
@testable import FunctionKit


class ConsumerTests: XCTestCase {
    func testConsumer() {
        var sum = 0
        var string = ""
        let addToSum: Consumer<Int> = .init { sum += $0 }
        let appendToString: Consumer<Int> = .init { string.append("\($0)") }

        let addToSumThenAppendToString = addToSum.then(appendToString)
        addToSumThenAppendToString.call(with: 5)
        addToSumThenAppendToString.call(with: 3)
        addToSumThenAppendToString.call(with: 2)

        XCTAssertEqual(sum, 10)
        XCTAssertEqual(string, "532")
    }
}

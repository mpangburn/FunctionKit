//
//  ProviderTests.swift
//  FunctionKitTests
//
//  Created by Michael Pangburn on 4/11/18.
//

import XCTest
@testable import FunctionKit


class ProviderTests: XCTestCase {
    func testSupplier() {
        let fiveProvider: Provider<Int> = .init { 5 }
        XCTAssertEqual(fiveProvider.make(), 5)
        XCTAssertEqual(fiveProvider.make(), 5)
        XCTAssertEqual(fiveProvider.make(), 5)
    }
}

//
//  ComparatorTests.swift
//  FunctionKitTests
//
//  Created by Michael Pangburn on 4/13/18.
//

import XCTest
@testable import FunctionKit

typealias Comparator = FunctionKit.Comparator

private struct Person: Equatable {
    let firstName: String
    let lastName: String
    let age: Int
}

class ComparatorTests: XCTestCase {
    private let mp = Person(firstName: "Michael", lastName: "Pangburn", age: 20)
    private let mj = Person(firstName: "Michael", lastName: "Jordan", age: 55)
    private let ab = Person(firstName: "Alison", lastName: "Brie", age: 35)
    private let bb = Person(firstName: "Bo", lastName: "Burnham", age: 27)

    private lazy var people = [mp, mj, ab, bb]

    func testComparatorComparable() {
        let numbers = [3, 2, 5, 4, 1]
        XCTAssertEqual(numbers.sorted(by: .naturalOrder()), [1, 2, 3, 4, 5])
        XCTAssertEqual(numbers.sorted(by: .reverseOrder()), [5, 4, 3, 2, 1])
    }

    func testComparatorComposed() {
        let firstNameComparator: Comparator<Person> = .comparing(by: { $0.firstName })
        XCTAssertEqual(people.sorted(by: firstNameComparator), people.sorted { $0.firstName < $1.firstName })

        let lastNameComparator: Comparator<Person> = .comparing(by: { $0.lastName })
        XCTAssertEqual(people.sorted(by: lastNameComparator), people.sorted { $0.lastName < $1.lastName })

        let firstThenLastNameComparator = firstNameComparator.thenComparing(by: lastNameComparator)
        XCTAssertEqual(people.sorted(by: firstThenLastNameComparator), [ab, bb, mj, mp])
        XCTAssertEqual(people.sorted(by: firstThenLastNameComparator.reversed()), [ab, bb, mj, mp].reversed())

        let firstNameThenAgeComparator = firstNameComparator.thenComparing(by: { $0.age })
        XCTAssertEqual(people.sorted(by: firstNameThenAgeComparator), [ab, bb, mp, mj])
        XCTAssertEqual(people.sorted(by: firstNameThenAgeComparator.reversed()), [ab, bb, mp, mj].reversed())
    }
}

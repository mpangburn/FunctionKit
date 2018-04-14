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

private struct User: Equatable {
    let name: String
    let email: String?
}

class ComparatorTests: XCTestCase {
    private let mp = Person(firstName: "Michael", lastName: "Pangburn", age: 20)
    private let mj = Person(firstName: "Michael", lastName: "Jordan", age: 55)
    private let ab = Person(firstName: "Alison", lastName: "Brie", age: 35)
    private let bb = Person(firstName: "Bo", lastName: "Burnham", age: 27)

    private lazy var people = [mp, mj, ab, bb]

    private let m_f = User(name: "Michael", email: "f@not.real")
    private let s_a = User(name: "Shirley", email: "a@not.real")
    private let f_nil = User(name: "Jeff", email: nil)
    private let a_nil = User(name: "Abed", email: nil)

    private lazy var users = [m_f, s_a, f_nil, a_nil]

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

    func testComparatorOptional() {
        let nilEmailsFirst: Comparator<User> = .nilValuesFirst(by: { $0.email })
        let usersByNilEmailsFirst = users.sorted(by: nilEmailsFirst)
        // standard lib sort is not a stable sort
        XCTAssert(usersByNilEmailsFirst == [f_nil, a_nil, s_a, m_f] || usersByNilEmailsFirst == [a_nil, f_nil, s_a, m_f])

        let nilEmailsLast: Comparator<User> = .nilValuesLast(by: { $0.email })
        let usersByNilEmailsLast = users.sorted(by: nilEmailsLast)
        // standard lib sort is not a stable sort
        XCTAssert(usersByNilEmailsLast == [s_a, m_f, f_nil, a_nil] || usersByNilEmailsLast == [s_a, m_f, a_nil, f_nil])

        let nilEmailsLastThenByName = nilEmailsLast.thenComparing(by: { $0.name })
        XCTAssertEqual(users.sorted(by: nilEmailsLastThenByName), [s_a, m_f, a_nil, f_nil])
    }
}

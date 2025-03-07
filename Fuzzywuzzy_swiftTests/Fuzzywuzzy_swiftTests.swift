import XCTest

@testable import Fuzzywuzzy_swift

class Fuzzywuzzy_swiftTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTokenSetRatio() {
        let strPairs = [
            ("some", ""), ("", "some"), ("", ""),
            ("fuzzy fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear"),
            ("fuzzy$*#&)$#(wuzzy*@()#*()!<><>was a bear", "wuzzy wuzzy fuzzy was a bear"),
        ]
        for (str1, str2) in strPairs {
            print("STR1: \(str1)")
            print("STR2: \(str2)")
            print("TOKEN SET RATIO: \(String.fuzzTokenSetRatio(str1: str1, str2: str2))")
            print("-----------------")
        }
    }

    func testTokenSortRatio() {
        let strPairs = [
            ("some", ""), ("", "some"), ("", ""),
            ("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear"),
            ("fuzzy$*#&)$#(wuzzy*@()#*()!<><>was a bear", "wuzzy fuzzy was a bear"),
        ]
        for (str1, str2) in strPairs {
            print("STR1: \(str1)")
            print("STR2: \(str2)")
            print("TOKEN SORT RATIO: \(String.fuzzTokenSortRatio(str1: str1, str2: str2))")
            print("-----------------")
        }
    }

    func testPartialRatio() {
        let strPairs = [
            ("some", ""), ("", "some"), ("", ""), ("abcd", "XXXbcdeEEE"),
            ("what a wonderful 世界", "wonderful 世"), ("this is a test", "this is a test!"),
        ]
        for (str1, str2) in strPairs {
            print("STR1: \(str1)")
            print("STR2: \(str2)")
            print("PARTIAL RATIO: \(String.fuzzPartialRatio(str1: str1, str2: str2))")
            print("-----------------")
        }
    }

    func testCommonSubstrings() {
        let strPairs = [
            ("some", ""), ("", "some"), ("", ""), ("aaabbcde", "abbdbcdaabde"),
            ("abcdef", "abcdef"),
        ]
        for (str1, str2) in strPairs {
            let pairs = CommonSubstrings.pairs(str1: str1, str2: str2)
            print("STR1: \(str1)")
            print("STR2: \(str2)")
            for pair in pairs {
                print("\(str1[pair.str1SubRange])")
                print("\(str2[pair.str2SubRange])")
                print("")
            }
            print("-----------------")
        }
    }

    func testStringMatcher() {
        let strPairs = [
            ("some", ""), ("", "some"), ("", ""), ("我好hungry", "我好饿啊啊啊啊"), ("我好饿啊啊啊啊", "好烦啊"),
        ]
        for (str1, str2) in strPairs {
            let matcher = StringMatcher(str1: str1, str2: str2)
            let ratio = matcher.fuzzRatio()
            XCTAssert(ratio <= 1 && ratio >= 0)
            print("STR1: \(str1)")
            print("STR2: \(str2)")
            print("RATIO: \(ratio)")
            print("-----------------")
        }
    }

    func testLevenshteinDistance() {
        XCTAssertEqual(LevenshteinDistance.distance(str1: "something", str2: "some"), 5)
        XCTAssertEqual(LevenshteinDistance.distance(str1: "something", str2: "omethi"), 3)
        XCTAssertEqual(LevenshteinDistance.distance(str1: "something", str2: "same"), 6)
    }

    // New Tests for FuzzySort Array Extensions
    func testFuzzySortStringArray() throws {
        let items = ["apple", "banana", "grape", "orange", "pineapple", "apricot"]
        let sorted = try items.fuzzySort(match: "app", scoreOption: .standard)
        XCTAssertEqual(sorted.prefix(3), ["apple", "grape", "pineapple"])
    }

    func testFuzzySortWithInvalidFloor() {
        let items = ["apple", "banana", "grape"]
        XCTAssertThrowsError(try items.fuzzySort(match: "app", floor: -1, scoreOption: .standard)) {
            error in
            XCTAssertEqual(error as? FuzzySortError, .invalidFloor)
        }
    }

    func testFuzzySortWithEmptyQuery() {
        let items = ["apple", "banana", "grape"]
        XCTAssertThrowsError(try items.fuzzySort(match: "", scoreOption: .standard)) { error in
            XCTAssertEqual(error as? FuzzySortError, .emptyQuery)
        }
    }

    func testFuzzySortWithCaseSensitivity() throws {
        let items = ["APPLE", "BANANA", "GRAPE", "ORANGE", "PINEAPPLE", "APRICOT"]
        let sorted = try items.fuzzySort(
            match: "apple", floor: 100, scoreOption: .standard, caseSensitive: true
        )
        XCTAssertEqual(sorted, [])
    }

    func testFuzzySortWithDifferentScoreOptions() throws {
        let items = ["apple", "banana", "grape", "orange", "pineapple", "apricot"]
        let standardSorted = try items.fuzzySort(match: "app", scoreOption: .standard)
        let partialSorted = try items.fuzzySort(match: "app", scoreOption: .partial)
        let tokenSetSorted = try items.fuzzySort(match: "app", scoreOption: .tokenSet)

        XCTAssertEqual(standardSorted.prefix(3), ["apple", "grape","pineapple"])
        XCTAssertEqual(partialSorted.prefix(3), ["apple", "grape","pineapple"])
        XCTAssertEqual(tokenSetSorted.prefix(3), ["apple", "grape","pineapple"])
    }
}

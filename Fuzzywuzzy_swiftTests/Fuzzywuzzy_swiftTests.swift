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

    // MARK: - Generic Array Extension Tests
    
    // Dummy struct for testing generic array extensions
    struct TestItem {
        let str: String
        let num: Int
        
        init(str: String, num: Int = 0) {
            self.str = str
            self.num = num
        }
    }
    
    func testFuzzySortGenericArray() throws {
        let items = [
            TestItem(str: "apple", num: 1),
            TestItem(str: "banana", num: 2),
            TestItem(str: "grape", num: 3),
            TestItem(str: "orange", num: 4),
            TestItem(str: "pineapple", num: 5),
            TestItem(str: "apricot", num: 6)
        ]
        
        // Test with default stringify function
        let sorted = try items.fuzzySort(
            match: TestItem(str: "app"),
            scoreOption: .standard
        )
        
        XCTAssertEqual(sorted.count, 6)
        XCTAssertEqual(sorted[0].str, "apple")
        
        // Test with custom stringify function
        let sortedCustom = try items.fuzzySort(
            query: "app",
            stringify: { item in item.str },
            scoreOption: .standard
        )
        
        XCTAssertEqual(sortedCustom.count, 6)
        XCTAssertEqual(sortedCustom[0].str, "apple")
    }
    
    func testFuzzyMapGenericArray() throws {
        let items = [
            TestItem(str: "apple", num: 1),
            TestItem(str: "banana", num: 2),
            TestItem(str: "grape", num: 3),
            TestItem(str: "orange", num: 4),
            TestItem(str: "pineapple", num: 5),
            TestItem(str: "apricot", num: 6)
        ]
        
        // Test fuzzyMap with match as TestItem
        let mapped = try items.fuzzyMap(
            match: TestItem(str: "app"),
            floor: 50,
            sorted: true,
            scoreOption: .standard
        )
        
        XCTAssertTrue(mapped.count <= 6)
        if !mapped.isEmpty {
            XCTAssertEqual(mapped[0].element.str, "apple")
            XCTAssertGreaterThanOrEqual(mapped[0].score, 50)
        }
        
        // Test fuzzyMap with query string and custom stringify
        let mappedCustom = try items.fuzzyMap(
            query: "app",
            floor: 50,
            sorted: true,
            stringify: { item in item.str },
            scoreOption: .standard
        )
        
        XCTAssertTrue(mappedCustom.count <= 6)
        if !mappedCustom.isEmpty {
            XCTAssertEqual(mappedCustom[0].element.str, "apple")
            XCTAssertGreaterThanOrEqual(mappedCustom[0].score, 50)
        }
    }
    
    func testGenericArrayWithDifferentScoreOptions() throws {
        let items = [
            TestItem(str: "apple", num: 1),
            TestItem(str: "banana", num: 2),
            TestItem(str: "grape", num: 3),
            TestItem(str: "orange", num: 4),
            TestItem(str: "pineapple", num: 5),
            TestItem(str: "apricot", num: 6)
        ]
        
        let standardSorted = try items.fuzzySort(
            query: "app",
            stringify: { item in item.str },
            scoreOption: .standard
        )
        
        let partialSorted = try items.fuzzySort(
            query: "app",
            stringify: { item in item.str },
            scoreOption: .partial
        )
        
        let tokenSetSorted = try items.fuzzySort(
            query: "app",
            stringify: { item in item.str },
            scoreOption: .tokenSet
        )
        
        XCTAssertEqual(standardSorted.prefix(3).map { $0.str }, ["apple", "grape", "pineapple"])
        XCTAssertEqual(partialSorted.prefix(3).map { $0.str }, ["apple", "grape", "pineapple"])
        XCTAssertEqual(tokenSetSorted.prefix(3).map { $0.str }, ["apple", "grape", "pineapple"])
    }
    
    func testGenericArrayWithInvalidParameters() {
        let items = [
            TestItem(str: "apple", num: 1),
            TestItem(str: "banana", num: 2),
            TestItem(str: "grape", num: 3)
        ]
        
        // Test with invalid floor
        XCTAssertThrowsError(try items.fuzzySort(
            match: TestItem(str: "app"),
            floor: -1,
            scoreOption: .standard
        )) { error in
            XCTAssertEqual(error as? FuzzySortError, .invalidFloor)
        }
        
        // Test with empty query using query parameter directly
        XCTAssertThrowsError(try items.fuzzySort(
            query: "",
            stringify: { item in item.str },
            scoreOption: .standard
        )) { error in
            XCTAssertEqual(error as? FuzzySortError, .emptyQuery)
        }
        
        // Test with empty query using match parameter and custom stringify
        XCTAssertThrowsError(try items.fuzzySort(
            match: TestItem(str: ""),
            stringify: { _ in "" },  // Force empty string
            scoreOption: .standard
        )) { error in
            XCTAssertEqual(error as? FuzzySortError, .emptyQuery)
        }
    }
    
    // MARK: - Additional FuzzyMap Tests
    
    func testFuzzyMapWithDifferentScoreOptions() throws {
        let items = ["apple", "banana", "grape", "orange", "pineapple", "apricot"]
        
        let standardMapped = try items.fuzzyMap(
            match: "app",
            floor: 0,
            sorted: true,
            scoreOption: .standard
        )
        
        let partialMapped = try items.fuzzyMap(
            match: "app",
            floor: 0,
            sorted: true,
            scoreOption: .partial
        )
        
        let tokenSetMapped = try items.fuzzyMap(
            match: "app",
            floor: 0,
            sorted: true,
            scoreOption: .tokenSet
        )
        
        let partialTokenSortMapped = try items.fuzzyMap(
            match: "app",
            floor: 0,
            sorted: true,
            scoreOption: .partialTokenSort
        )
        
        // Check that all mapping methods return results
        XCTAssertFalse(standardMapped.isEmpty)
        XCTAssertFalse(partialMapped.isEmpty)
        XCTAssertFalse(tokenSetMapped.isEmpty)
        XCTAssertFalse(partialTokenSortMapped.isEmpty)
        
        // Check that the first result is "apple" for all methods
        XCTAssertEqual(standardMapped[0].element, "apple")
        XCTAssertEqual(partialMapped[0].element, "apple")
        XCTAssertEqual(tokenSetMapped[0].element, "apple")
        XCTAssertEqual(partialTokenSortMapped[0].element, "apple")
    }
    
    func testFuzzyMapWithCaseSensitivity() throws {
        let items = ["APPLE", "BANANA", "GRAPE", "ORANGE", "PINEAPPLE", "APRICOT"]
        
        // Case-insensitive search should find matches
        let caseInsensitiveMapped = try items.fuzzyMap(
            match: "apple",
            floor: 0,
            sorted: true,
            caseSensitive: false,
            scoreOption: .standard
        )
        
        // Case-sensitive search with high floor should find no matches
        let caseSensitiveMapped = try items.fuzzyMap(
            match: "apple",
            floor: 100,
            sorted: true,
            caseSensitive: true,
            scoreOption: .standard
        )
        
        XCTAssertFalse(caseInsensitiveMapped.isEmpty)
        XCTAssertEqual(caseInsensitiveMapped[0].element, "APPLE")
        XCTAssertTrue(caseSensitiveMapped.isEmpty)
    }
    
    func testFuzzyMapWithFloorFiltering() throws {
        let items = ["apple", "banana", "grape", "orange", "pineapple", "apricot"]
        
        // Low floor should include all items
        let lowFloorMapped = try items.fuzzyMap(
            match: "app",
            floor: 0,
            sorted: true,
            scoreOption: .standard
        )
        
        // Medium floor should include some items
        let mediumFloorMapped = try items.fuzzyMap(
            match: "app",
            floor: 50,
            sorted: true,
            scoreOption: .standard
        )
        
        // High floor should include fewer items
        let highFloorMapped = try items.fuzzyMap(
            match: "app",
            floor: 80,
            sorted: true,
            scoreOption: .standard
        )
        
        XCTAssertEqual(lowFloorMapped.count, 6)
        XCTAssertTrue(mediumFloorMapped.count < lowFloorMapped.count)
        XCTAssertTrue(highFloorMapped.count <= mediumFloorMapped.count)
    }
    
    func testFuzzyMapGenericArrayWithDifferentScoreOptions() throws {
        let items = [
            TestItem(str: "apple", num: 1),
            TestItem(str: "banana", num: 2),
            TestItem(str: "grape", num: 3),
            TestItem(str: "orange", num: 4),
            TestItem(str: "pineapple", num: 5),
            TestItem(str: "apricot", num: 6)
        ]
        
        let standardMapped = try items.fuzzyMap(
            query: "app",
            floor: 0,
            sorted: true,
            stringify: { item in item.str },
            scoreOption: .standard
        )
        
        let partialMapped = try items.fuzzyMap(
            query: "app",
            floor: 0,
            sorted: true,
            stringify: { item in item.str },
            scoreOption: .partial
        )
        
        let tokenSetMapped = try items.fuzzyMap(
            query: "app",
            floor: 0,
            sorted: true,
            stringify: { item in item.str },
            scoreOption: .tokenSet
        )
        
        // Check that all mapping methods return results
        XCTAssertFalse(standardMapped.isEmpty)
        XCTAssertFalse(partialMapped.isEmpty)
        XCTAssertFalse(tokenSetMapped.isEmpty)
        
        // Check that the first result is the item with "apple" for all methods
        XCTAssertEqual(standardMapped[0].element.str, "apple")
        XCTAssertEqual(partialMapped[0].element.str, "apple")
        XCTAssertEqual(tokenSetMapped[0].element.str, "apple")
        
        // Check that scores are included
        XCTAssertGreaterThan(standardMapped[0].score, 0)
        XCTAssertGreaterThan(partialMapped[0].score, 0)
        XCTAssertGreaterThan(tokenSetMapped[0].score, 0)
    }
    
    func testFuzzyMapGenericArrayWithFullProcess() throws {
        let items = [
            TestItem(str: "apple pie", num: 1),
            TestItem(str: "banana split", num: 2),
            TestItem(str: "grape juice", num: 3),
            TestItem(str: "orange juice", num: 4),
            TestItem(str: "pineapple cake", num: 5),
            TestItem(str: "apricot tart", num: 6)
        ]
        
        // With full processing
        let withFullProcess = try items.fuzzyMap(
            query: "apple",
            floor: 0,
            sorted: true,
            stringify: { item in item.str },
            fullProcess: true,
            scoreOption: .tokenSet
        )
        
        // Without full processing
        let withoutFullProcess = try items.fuzzyMap(
            query: "apple",
            floor: 0,
            sorted: true,
            stringify: { item in item.str },
            fullProcess: false,
            scoreOption: .tokenSet
        )
        
        // Both should find matches but potentially with different scores
        XCTAssertFalse(withFullProcess.isEmpty)
        XCTAssertFalse(withoutFullProcess.isEmpty)
        
        // The first item should be "apple pie" in both cases
        XCTAssertEqual(withFullProcess[0].element.str, "apple pie")
        XCTAssertEqual(withoutFullProcess[0].element.str, "apple pie")
    }
}

//
//  Fuzzy_Array_Search.swift
//  Fuzzywuzzy_swift
//
//  Created by Jason Boyett on 2/26/25.
//  Copyright © 2025 LiXian. All rights reserved.
//

import Foundation

/// Errors that can occur during fuzzy search and sort operations.
public enum FuzzySortError: Error {
    /// Thrown when the provided floor value is not within the valid range (0 to 100).
    case invalidFloor
    /// Thrown when the query string is empty.
    case emptyQuery
}

/// Options for selecting the fuzzy scoring algorithm.
public enum FuzzyScoreOptions {
    /// Uses the standard fuzzy ratio algorithm.
    case standard
    /// Uses the partial fuzzy ratio algorithm.
    case partial
    /// Uses the partial token sort ratio algorithm.
    case partialTokenSort
    /// Uses the token set ratio algorithm.
    case tokenSet
}

extension Array where Element == String {
    /// Maps each element in the string array to a fuzzy matching score against the provided query string.
    ///
    /// - Parameters:
    ///   - match: The query string to compare each element against.
    ///   - floor: The minimum score (0 to 100) required for an element to be included. Defaults to 0.
    ///   - sorted: A Boolean indicating whether the resulting array should be sorted in descending order by score. Defaults to false.
    ///   - caseSensitive: A Boolean indicating whether matching should be case-sensitive. Defaults to false.
    ///   - stringify: A closure that converts an element to its string representation. Defaults to using `String(describing:)`.
    ///   - fullProcess: A Boolean indicating whether full token processing should be applied. Defaults to true.
    ///   - scoreOption: The fuzzy scoring algorithm to use. Defaults to .standard
    /// - Returns: An array of tuples where each tuple contains the string element and its corresponding fuzzy match score.
    /// - Throws: `FuzzySortError.invalidFloor` if the floor value is not between 0 and 100, or `FuzzySortError.emptyQuery` if the query is empty.
    public func fuzzyMap(
        match: String,
        floor: Int = 0,
        sorted: Bool = false,
        caseSensitive: Bool = false,
        stringify: ((Element) -> String) = { element in String(describing: element) },
        fullProcess: Bool = true,
        scoreOption: FuzzyScoreOptions = .standard
    ) throws -> [(element: String, score: Int)] {
        return try self.fuzzyMap(
            query: match,
            floor: floor,
            sorted: sorted,
            caseSensitive: caseSensitive,
            fullProcess: fullProcess,
            scoreOption: scoreOption
        )
    }

    /// Sorts the string array based on fuzzy matching against the provided query string.
    ///
    /// - Parameters:
    ///   - match: The query string used for fuzzy matching.
    ///   - floor: The minimum score (0 to 100) required for an element to be included. Defaults to 0.
    ///   - caseSensitive: A Boolean indicating whether matching should be case-sensitive. Defaults to false.
    ///   - fullProcess: A Boolean indicating whether full token processing should be applied. Defaults to true.
    ///   - scoreOption: The fuzzy scoring algorithm to use. Defaults to .standard
    /// - Returns: A sorted array of strings (in descending order by score) that match the query.
    /// - Throws: `FuzzySortError.invalidFloor` if the floor value is invalid, or `FuzzySortError.emptyQuery` if the query is empty.
    public func fuzzySort(
        match: String,
        floor: Int = 0,
        caseSensitive: Bool = false,
        fullProcess: Bool = true,
        scoreOption: FuzzyScoreOptions = .standard
    ) throws -> [String] {
        return try self.fuzzySort(
            query: match,
            floor: floor,
            caseSensitive: caseSensitive,
            fullProcess: fullProcess,
            scoreOption: scoreOption
        )
    }
}

extension Array where Element: Any {

    /// Sorts the array based on fuzzy matching scores against the provided query element.
    ///
    /// - Parameters:
    ///   - match: The query element. Its string representation is derived using the `stringify` closure.
    ///   - floor: The minimum fuzzy score (0 to 100) required for an element to be included. Defaults to 0.
    ///   - caseSensitive: A Boolean indicating whether matching should be case-sensitive. Defaults to false.
    ///   - stringify: A closure that converts an element to a string. Defaults to using `String(describing:)`.
    ///   - scoreOption: The fuzzy scoring algorithm to use. Defaults to `.standard`.
    ///   - fullProcess: A Boolean indicating whether full token processing should be applied. Defaults to true.
    /// - Returns: A sorted array of elements (in descending order by score) that match the query.
    /// - Throws: `FuzzySortError.invalidFloor` if the floor is not in the valid range, or `FuzzySortError.emptyQuery` if the query is empty.
    public func fuzzySort(
        match: Element,
        floor: Int = 0,
        caseSensitive: Bool = false,
        stringify: ((Element) -> String) = { element in String(describing: element) },
        scoreOption: FuzzyScoreOptions = .standard,
        fullProcess: Bool = true
    ) throws -> [Element] {
        let query = stringify(match)

        return try self.fuzzySort(
            query: query,
            floor: floor,
            caseSensitive: caseSensitive,
            stringify: stringify,
            fullProcess: fullProcess,
            scoreOption: scoreOption
        )
    }

    /// Maps each element of the array to a tuple containing the element and its fuzzy match score against the provided query element.
    ///
    /// - Parameters:
    ///   - match: The query element whose string representation is derived via the `stringify` closure.
    ///   - floor: The minimum score (0 to 100) required for an element to be included. Defaults to 0.
    ///   - sorted: A Boolean indicating whether the resulting array should be sorted in descending order by score. Defaults to false.
    ///   - caseSensitive: A Boolean specifying whether matching should be case-sensitive. Defaults to false.
    ///   - stringify: A closure that converts an element to its string representation. Defaults to using `String(describing:)`.
    ///   - fullProcess: A Boolean indicating whether full token processing should be applied. Defaults to true.
    ///   - scoreOption: The fuzzy scoring algorithm to use. Defaults to .standard
    /// - Returns: An array of tuples where each tuple contains the element and its corresponding fuzzy match score.
    /// - Throws: `FuzzySortError.invalidFloor` if the floor value is out of range, or `FuzzySortError.emptyQuery` if the query is empty.
    public func fuzzyMap(
        match: Element,
        floor: Int = 0,
        sorted: Bool = false,
        caseSensitive: Bool = false,
        stringify: ((Element) -> String) = { element in String(describing: element) },
        fullProcess: Bool = true,
        scoreOption: FuzzyScoreOptions = .standard
    ) throws -> [(element: Element, score: Int)] {
        let query = stringify(match)

        return try self.fuzzyMap(
            query: query,
            floor: floor,
            sorted: sorted,
            caseSensitive: caseSensitive,
            stringify: stringify,
            fullProcess: fullProcess,
            scoreOption: scoreOption
        )
    }

    /// Sorts the array based on fuzzy matching scores calculated using a query string.
    ///
    /// - Parameters:
    ///   - query: The query string used for fuzzy matching.
    ///   - floor: The minimum acceptable score (0 to 100) for an element to be included. Defaults to 0.
    ///   - caseSensitive: A Boolean specifying whether the matching should be case-sensitive. Defaults to false.
    ///   - stringify: A closure that converts an element into its string representation. Defaults to using `String(describing:)`.
    ///   - fullProcess: A Boolean indicating whether full token processing should be applied. Defaults to true.
    ///   - scoreOption: The fuzzy scoring algorithm to use. Defaults to .standard
    /// - Returns: A sorted array of elements that match the query, sorted in descending order by fuzzy score.
    /// - Throws: `FuzzySortError.invalidFloor` if the floor value is not valid, or `FuzzySortError.emptyQuery` if the query is empty.
    public func fuzzySort(
        query: String,
        floor: Int = 0,
        caseSensitive: Bool = false,
        stringify: ((Element) -> String) = { element in String(describing: element) },
        fullProcess: Bool = true,
        scoreOption: FuzzyScoreOptions = .standard
    ) throws -> [Element] {

        return try self.fuzzyMap(
            query: query,
            floor: floor,
            sorted: true,
            caseSensitive: caseSensitive,
            stringify: stringify,
            fullProcess: fullProcess,
            scoreOption: scoreOption
        )
        .map { $0.element }
    }

    /// Maps each element of the array to a tuple containing the element and its fuzzy match score using a query string.
    ///
    /// - Parameters:
    ///   - query: The query string used for fuzzy matching.
    ///   - floor: The minimum score (0 to 100) required for an element to be included. Defaults to 0.
    ///   - sorted: A Boolean indicating whether the resulting array should be sorted in descending order by score. Defaults to false.
    ///   - caseSensitive: A Boolean specifying whether matching should be case-sensitive. Defaults to false.
    ///   - stringify: A closure that converts an element into its string representation. Defaults to using `String(describing:)`.
    ///   - fullProcess: A Boolean indicating whether full token processing should be applied. Defaults to true.
    ///   - scoreOption: The fuzzy scoring algorithm to use.
    /// - Returns: An array of tuples where each tuple contains the element and its corresponding fuzzy match score.
    /// - Throws: `FuzzySortError.invalidFloor` if the floor value is out of range, or `FuzzySortError.emptyQuery` if the query is empty.
    public func fuzzyMap(
        query: String,
        floor: Int = 0,
        sorted: Bool = false,
        caseSensitive: Bool = false,
        stringify: ((Element) -> String) = { element in String(describing: element) },
        fullProcess: Bool = true,
        scoreOption: FuzzyScoreOptions = .standard
    ) throws -> [(element: Element, score: Int)] {

        guard floor >= 0 && floor <= 100 else { throw FuzzySortError.invalidFloor }
        guard !query.isEmpty else { throw FuzzySortError.emptyQuery }

        let result = self.compactMap { item -> (element: Element, score: Int)? in
            let selfString = stringify(item)
            let score = _calculateScore(
                str1: !caseSensitive
                    ? query.lowercased()
                    : query,
                str2: !caseSensitive
                    ? selfString.lowercased()
                    : selfString,
                fullProcess: fullProcess,
                scoreOption: scoreOption
            )
            return score >= floor ? (item, score) : nil
        }

        return !sorted ? result : result.sorted { $0.score > $1.score }
    }
}

/// Private helper function to calculate the fuzzy matching score between two strings.
///
/// - Parameters:
///   - str1: The first string (typically the query).
///   - str2: The second string (typically the target string).
///   - fullProcess: A Boolean indicating whether full token processing should be applied.
///   - scoreOption: The fuzzy scoring algorithm to use.
/// - Returns: An integer representing the fuzzy match score between the two strings.
private func _calculateScore(
    str1: String,
    str2: String,
    fullProcess: Bool,
    scoreOption: FuzzyScoreOptions
) -> Int {
    switch scoreOption {
    case .standard:
        return String.fuzzRatio(str1: str1, str2: str2)
    case .partial:
        return String.fuzzPartialRatio(str1: str1, str2: str2)
    case .tokenSet:
        return String.fuzzTokenSetRatio(
            str1: str1, str2: str2, fullProcess: fullProcess
        )
    case .partialTokenSort:
        return String.fuzzPartialTokenSetRatio(
            str1: str1, str2: str2, fullProcess: fullProcess
        )
    }
}

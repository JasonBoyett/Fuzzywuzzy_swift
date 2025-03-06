//
//  Fuzzy_Array_Search.swift
//  Fuzzywuzzy_swift
//
//  Created by Jason Boyett on 2/26/25.
//  Copyright © 2025 LiXian. All rights reserved.
//

import Foundation

public enum FuzzySortError: Error {
    case invalidFloor
    case emptyQuery
}

public enum FuzzyScoreOptions {
    case standard
    case partial
    case partialTokenSort
    case tokenSet
}

extension Array where Element == String {
    public func fuzzySort(
        match: String,
        floor: Int = 0,
        fullProcess: Bool = true,
        scoreOption: FuzzyScoreOptions,
        caseSensitive: Bool = false
    ) throws -> [String] {
        return try self.fuzzySort(
            query: match,
            floor: floor,
            fullProcess: fullProcess,
            scoreOption: scoreOption,
            caseSensitive: caseSensitive
        )
    }
}

extension Array where Element: Any {

    public func fuzzySort(
        match: Element,
        floor: Int = 0,
        stringify: ((Element) -> String) = { element in String(describing: element) },
        scoreOption: FuzzyScoreOptions = .standard,
        fullProcess: Bool = true,
        caseSensitive: Bool = false
    ) throws -> [Element] {
        let query = stringify(match)

        return try self.fuzzySort(
            query: query,
            floor: floor,
            stringify: stringify,
            fullProcess: fullProcess,
            scoreOption: scoreOption,
            caseSensitive: caseSensitive
        )
    }

    public func fuzzySort(
        query: String,
        floor: Int = 0,
        stringify: ((Element) -> String) = { element in String(describing: element) },
        fullProcess: Bool = true,
        scoreOption: FuzzyScoreOptions,
        caseSensitive: Bool = false
    ) throws -> [Element] {
        guard floor >= 0 && floor <= 100 else { throw FuzzySortError.invalidFloor }
        guard !query.isEmpty else { throw FuzzySortError.emptyQuery }

        return self.compactMap { item -> (item: Element, score: Int)? in
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
        .sorted { $0.score > $1.score }
        .map { $0.item }
    }

}

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

import Foundation

struct CommonSubstringPair {
    let str1SubRange: Range<String.Index>
    let str2SubRange: Range<String.Index>
    let len: Int
}

class CommonSubstrings {
    /// Get all pairs of common substrings
    class func pairs(str1: String, str2: String) -> [CommonSubstringPair] {
        guard !str1.isEmpty, !str2.isEmpty else { return [] }

        // Convert Strings to Array of Characters
        let charArr1 = Array(str1)
        let charArr2 = Array(str2)

        // Create the matching matrix
        var matchingM = Array(repeating: Array(repeating: 0, count: charArr2.count + 1), count: charArr1.count + 1)

        var pairs: [CommonSubstringPair] = []

        for i in 1...charArr1.count {
            for j in 1...charArr2.count {
                if charArr1[i - 1] == charArr2[j - 1] {
                    matchingM[i][j] = matchingM[i - 1][j - 1] + 1

                    // Find length of matching substring
                    var len = matchingM[i][j]
                    let sub1Start = str1.index(str1.startIndex, offsetBy: i - len)
                    let sub1End = str1.index(str1.startIndex, offsetBy: i)
                    let sub2Start = str2.index(str2.startIndex, offsetBy: j - len)
                    let sub2End = str2.index(str2.startIndex, offsetBy: j)

                    pairs.append(CommonSubstringPair(
                        str1SubRange: sub1Start..<sub1End,
                        str2SubRange: sub2Start..<sub2End,
                        len: len
                    ))
                }
            }
        }

        return pairs
    }
}

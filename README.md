# Fuzzywuzzy_swift
Fuzzy String Matching in Swift using Levenshtein Distance. Ported from the python fuzzywuzzy library https://github.com/seatgeek/fuzzywuzzy

It has no external dependancies. And thanks to Swift String, it can support multi-language.

# Installation
### Carthage
Add the following line to your Cartfile. And run `carthage update`
```
github "lxian/Fuzzywuzzy_swift"
```
### Cocoapod
Add the following line to your Podfile. And run `pod install`
```
pod 'Fuzzywuzzy_swift', :git=> 'https://github.com/lxian/Fuzzywuzzy_swift.git'
```
### Manually
drag the `Fuzzywuzzy_swift` folder into your project

# Usage
```swift
import Fuzzywuzzy_swift
```
### Simple Ratio
```swift
String.fuzzRatio(str1: "some text here", str2: "same text here!") // => 93
```

### Partial Ratio
Partial Ratio tries to match the shoter string to a substring of the longer one
```swift
String.fuzzPartialRatio(str1: "some text here", str2: "I found some text here!") // => 100
```
### Token Sort Ratio
Split strings by white space into arrays of tokens. Sort two arrays of Tokens. Calculate the effort needed to transform on arry of token into another. Characters other than letters and numbers are removed as a pre-processing by default.
```swift
String.fuzzTokenSortRatio(str1: "fuzzy wuzzy was a bear", str2: "wuzzy fuzzy was a bear") // => 100

String.fuzzTokenSortRatio(str1: "fuzzy+wuzzy(was) a bear", str2: "wuzzy fuzzy was a bear") // => 100
```
set fullProcess to false to remove this pre-processing
```swift
String.fuzzTokenSortRatio(str1: "fuzzy+wuzzy(was) a bear", str2: "wuzzy fuzzy was a bear", fullProcess: false) // => 77
```
### Token Set Ratio
Similiar to token sort ratio while it put tokens into a set trying to remove duplicated tokens.
```swift
String.fuzzTokenSortRatio(str1: "fuzzy was a bear", str2: "fuzzy fuzzy was a bear") // => 84

String.fuzzTokenSetRatio(str1: "fuzzy was a bear", str2: "fuzzy fuzzy was a bear") // => 100
```

## Array Extensions

Fuzzywuzzy_swift provides powerful extensions for arrays that allow you to perform fuzzy searching and sorting on collections.

### String Arrays

#### Fuzzy Sort
Sort a string array based on fuzzy matching against a query string:

```swift
let fruits = ["apple", "banana", "grape", "orange", "pineapple", "apricot"]

// Sort by similarity to "app" using standard algorithm
let sorted = try fruits.fuzzySort(match: "app", scoreOption: .standard)
// => ["apple", "grape", "pineapple", ...]

// With minimum score threshold
let highScoreOnly = try fruits.fuzzySort(match: "app", floor: 70, scoreOption: .standard)

// Using different algorithms
let partialMatches = try fruits.fuzzySort(match: "app", scoreOption: .partial)
let tokenSetMatches = try fruits.fuzzySort(match: "app", scoreOption: .tokenSet)
let partialTokenMatches = try fruits.fuzzySort(match: "app", scoreOption: .partialTokenSort)

// Case-sensitive matching
let caseSensitive = try fruits.fuzzySort(match: "App", caseSensitive: true, scoreOption: .standard)
```

#### Fuzzy Map
Map a string array to tuples containing the original string and its fuzzy match score:

```swift
let fruits = ["apple", "banana", "grape", "orange", "pineapple", "apricot"]

// Map with scores using standard algorithm
let mappedWithScores = try fruits.fuzzyMap(match: "app", scoreOption: .standard)
// => [("apple", 86), ("grape", 57), ...]

// Sort results by score
let sortedWithScores = try fruits.fuzzyMap(match: "app", sorted: true, scoreOption: .standard)

// Filter by minimum score
let highScoresOnly = try fruits.fuzzyMap(match: "app", floor: 70, sorted: true, scoreOption: .standard)
```

### Generic Arrays

The library also supports fuzzy matching on arrays of any type by providing a way to extract a string representation from each element.

#### Fuzzy Sort for Custom Types

```swift
struct Person {
    let name: String
    let age: Int
}

let people = [
    Person(name: "John Smith", age: 25),
    Person(name: "Jane Doe", age: 30),
    Person(name: "John Doe", age: 40)
]

// Sort by name similarity to "John"
let sortedPeople = try people.fuzzySort(
    query: "John",
    stringify: { person in person.name },
    scoreOption: .standard
)
// => [Person(name: "John Smith", age: 25), Person(name: "John Doe", age: 40), ...]

// Or use an object of the same type as a query
let queryPerson = Person(name: "John", age: 0)
let matchedPeople = try people.fuzzySort(
    match: queryPerson,
    stringify: { person in person.name },
    scoreOption: .standard
)
```

#### Fuzzy Map for Custom Types

```swift
// Map people to tuples with their fuzzy match scores
let peopleWithScores = try people.fuzzyMap(
    query: "John",
    floor: 50,
    sorted: true,
    stringify: { person in person.name },
    scoreOption: .standard
)
// => [(Person(name: "John Smith", age: 25), 90), (Person(name: "John Doe", age: 40), 86), ...]

// Access the scores
for (person, score) in peopleWithScores {
    print("\(person.name): \(score)")
}
```

### Available Score Options

- `.standard`: Uses the standard fuzzy ratio algorithm
- `.partial`: Uses the partial fuzzy ratio algorithm
- `.tokenSet`: Uses the token set ratio algorithm
- `.partialTokenSort`: Uses the partial token sort ratio algorithm

### Error Handling

The fuzzy functions can throw errors in certain cases:

```swift
do {
    let results = try fruits.fuzzySort(match: "app", floor: -10, scoreOption: .standard)
} catch FuzzySortError.invalidFloor {
    print("Floor value must be between 0 and 100")
} catch FuzzySortError.emptyQuery {
    print("Query string cannot be empty")
} catch {
    print("An unexpected error occurred")
}
```


import Foundation

/*
 --- Day 14: Extended Polymerization ---

 The incredible pressures at this depth are starting to put a strain on your submarine. The submarine has polymerization equipment that would produce suitable materials to reinforce the submarine, and the nearby volcanically-active caves should even have the necessary input elements in sufficient quantities.

 The submarine manual contains instructions for finding the optimal polymer formula; specifically, it offers a polymer template and a list of pair insertion rules (your puzzle input). You just need to work out what polymer would result after repeating the pair insertion process a few times.

 For example:

 NNCB

 CH -> B
 HH -> N
 CB -> H
 NH -> C
 HB -> C
 HC -> B
 HN -> C
 NN -> C
 BH -> H
 NC -> B
 NB -> B
 BN -> B
 BB -> N
 BC -> B
 CC -> N
 CN -> C
 The first line is the polymer template - this is the starting point of the process.

 The following section defines the pair insertion rules. A rule like AB -> C means that when elements A and B are immediately adjacent, element C should be inserted between them. These insertions all happen simultaneously.

 So, starting with the polymer template NNCB, the first step simultaneously considers all three pairs:

 The first pair (NN) matches the rule NN -> C, so element C is inserted between the first N and the second N.
 The second pair (NC) matches the rule NC -> B, so element B is inserted between the N and the C.
 The third pair (CB) matches the rule CB -> H, so element H is inserted between the C and the B.
 Note that these pairs overlap: the second element of one pair is the first element of the next pair. Also, because all pairs are considered simultaneously, inserted elements are not considered to be part of a pair until the next step.

 After the first step of this process, the polymer becomes NCNBCHB.

 Here are the results of a few steps using the above rules:

 Template:     NNCB
 After step 1: NCNBCHB
 After step 2: NBCCNBBBCBHCB
 After step 3: NBBBCNCCNBBNBNBBCHBHHBCHB
 After step 4: NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB
 This polymer grows quickly. After step 5, it has length 97; After step 10, it has length 3073. After step 10, B occurs 1749 times, C occurs 298 times, H occurs 161 times, and N occurs 865 times; taking the quantity of the most common element (B, 1749) and subtracting the quantity of the least common element (H, 161) produces 1749 - 161 = 1588.

 Apply 10 steps of pair insertion to the polymer template and find the most and least common elements in the result. What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?
 */

// MARK: - Input

let template = (try Input(fileName: "template").load(as: [String].self))[0]
let input = try Input.14.load(as: [String].self)

// MARK: - Solution 1

struct Polymerization {
    let rules: [String: String]
    let template: String
    var polymer: String
    
    private var counts: [String: Int]
    private var pairs: [String: Int]
    
    init(_ input: [String], _ template: String) {
        var dict = [String: String]()
        for line in input {
            let rule = line.components(separatedBy: "->").map { $0.trimmingCharacters(in: .whitespaces) }
            dict[rule[0].trimmingCharacters(in: .whitespaces)] = String(rule[1])
        }
        self.rules = dict
        self.template = template
        self.polymer = template
        
        self.counts = [String: Int]()
        self.pairs = [String: Int]()
        let poly = Array(polymer)
        for i in 0..<polymer.count {
            updateCount(String(poly[i]), 1)
            guard i < poly.count-1 else { continue }
            updatePairs("\(poly[i])\(poly[i+1])")
        }
    }
    
    private mutating func updateCount(_ letter: String, _ increment: Int) {
        counts[letter] = counts[letter, default: 0] + increment
    }
    
    private mutating func updatePairs(_ pair: String) {
        pairs[pair] = pairs[pair, default: 0] + 1
    }
    
    mutating func performSteps(_ steps: Int) {
        for _ in 0..<steps {
            let poly = Array(polymer)
            var newPoly = String(poly[0])
            for i in 0..<polymer.count-1 {
                let pair: String = String("\(poly[i])\(poly[i+1])")
                if let letter = rules[pair] {
                    newPoly += letter
                    updateCount(letter, 1)
                }
                newPoly += String(poly[i+1])
            }
            polymer = newPoly
        }
    }
    
    mutating func performOptimizedSteps(_ steps: Int) {
        for _ in 0..<steps {
            var newPairs = [String: Int]()
            for pair: String in pairs.keys {
                guard let count = pairs[pair] else { continue }
                if let letter = rules[pair] {
                    updateCount(letter, count)
                    let newPair1 = String(Array(pair)[0]) + letter
                    let newPair2 = letter + String(Array(pair)[1])
                    newPairs[newPair1] = newPairs[newPair1, default: 0] + count
                    newPairs[newPair2] = newPairs[newPair2, default: 0] + count
                } else {
                    newPairs[pair] = count
                }
            }
            pairs = newPairs
        }
    }
    
    func analyze() -> Int {
        var most: Int = 0
        var least: Int = Int(INT_MAX)
        
        for key in counts.keys {
            guard let count = counts[key] else { continue }
            most = max(most, count)
            least = min(least, count)
        }
        
        return most - least
    }
    
}

func Solution1(_ input: [String], _ template: String) -> Int {
    var poly = Polymerization(input, template)
    poly.performOptimizedSteps(10)
    return poly.analyze()
}

Solution1(input, template)
// 2003

/*
 --- Part Two ---

 The resulting polymer isn't nearly strong enough to reinforce the submarine. You'll need to run more steps of the pair insertion process; a total of 40 steps should do it.

 In the above example, the most common element is B (occurring 2192039569602 times) and the least common element is H (occurring 3849876073 times); subtracting these produces 2188189693529.

 Apply 40 steps of pair insertion to the polymer template and find the most and least common elements in the result. What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?
 */

func Solution2(_ input: [String], _ template: String) -> Int {
    var poly = Polymerization(input, template)
    poly.performOptimizedSteps(40)
    return poly.analyze()
}

Solution2(input, template)
// 2276644000111

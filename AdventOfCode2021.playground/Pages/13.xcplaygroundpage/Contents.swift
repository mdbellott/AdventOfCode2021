import Foundation

/*
 --- Day 13: Transparent Origami ---

 You reach another volcanically active part of the cave. It would be nice if you could do some kind of thermal imaging so you could tell ahead of time which caves are too hot to safely enter.

 Fortunately, the submarine seems to be equipped with a thermal camera! When you activate it, you are greeted with:

 Congratulations on your purchase! To activate this infrared thermal imaging
 camera system, please enter the code found on page 1 of the manual.
 Apparently, the Elves have never used this feature. To your surprise, you manage to find the manual; as you go to open it, page 1 falls out. It's a large sheet of transparent paper! The transparent paper is marked with random dots and includes instructions on how to fold it up (your puzzle input). For example:

 6,10
 0,14
 9,10
 0,3
 10,4
 4,11
 6,0
 6,12
 4,1
 0,13
 10,12
 3,4
 3,0
 8,4
 1,10
 2,14
 8,10
 9,0

 fold along y=7
 fold along x=5
 The first section is a list of dots on the transparent paper. 0,0 represents the top-left coordinate. The first value, x, increases to the right. The second value, y, increases downward. So, the coordinate 3,0 is to the right of 0,0, and the coordinate 0,7 is below 0,0. The coordinates in this example form the following pattern, where # is a dot on the paper and . is an empty, unmarked position:

 ...#..#..#.
 ....#......
 ...........
 #..........
 ...#....#.#
 ...........
 ...........
 ...........
 ...........
 ...........
 .#....#.##.
 ....#......
 ......#...#
 #..........
 #.#........
 Then, there is a list of fold instructions. Each instruction indicates a line on the transparent paper and wants you to fold the paper up (for horizontal y=... lines) or left (for vertical x=... lines). In this example, the first fold instruction is fold along y=7, which designates the line formed by all of the positions where y is 7 (marked here with -):

 ...#..#..#.
 ....#......
 ...........
 #..........
 ...#....#.#
 ...........
 ...........
 -----------
 ...........
 ...........
 .#....#.##.
 ....#......
 ......#...#
 #..........
 #.#........
 Because this is a horizontal line, fold the bottom half up. Some of the dots might end up overlapping after the fold is complete, but dots will never appear exactly on a fold line. The result of doing this fold looks like this:

 #.##..#..#.
 #...#......
 ......#...#
 #...#......
 .#.#..#.###
 ...........
 ...........
 Now, only 17 dots are visible.

 Notice, for example, the two dots in the bottom left corner before the transparent paper is folded; after the fold is complete, those dots appear in the top left corner (at 0,0 and 0,1). Because the paper is transparent, the dot just below them in the result (at 0,3) remains visible, as it can be seen through the transparent paper.

 Also notice that some dots can end up overlapping; in this case, the dots merge together and become a single dot.

 The second fold instruction is fold along x=5, which indicates this line:

 #.##.|#..#.
 #...#|.....
 .....|#...#
 #...#|.....
 .#.#.|#.###
 .....|.....
 .....|.....
 Because this is a vertical line, fold left:

 #####
 #...#
 #...#
 #...#
 #####
 .....
 .....
 The instructions made a square!

 The transparent paper is pretty big, so for now, focus on just completing the first fold. After the first fold in the example above, 17 dots are visible - dots that end up overlapping after the fold is completed count as a single dot.

 How many dots are visible after completing just the first fold instruction on your transparent paper?
 */

// MARK: - Input

let input = try Input.13.load(as: [String].self)
let folds = try Input(fileName: "folds").load(as: [String].self)
let test = try Input(fileName: "test-13").load(as: [String].self)
let testFolds = try Input(fileName: "testFolds").load(as: [String].self)

// MARK: - Model

enum Fold {
    case veritcal(pos: Int)
    case horizontal(pos: Int)
}

struct Dot: Hashable {
    let x: Int
    let y: Int
}

struct Paper {
    var dots = Set<Dot>()
    var maxX = 0
    var maxY = 0
    var dotCount: Int { return dots.count }
    
    init(dots: Set<Dot>, maxX: Int, maxY: Int) {
        self.dots = dots
        self.maxX = maxX
        self.maxY = maxY
    }
    
    mutating func fold(_ fold: Fold) {
        switch fold {
        case let .veritcal(val):
            foldLeft(val)
        case let .horizontal(val):
            foldUp(val)
        }
    }
    
    private mutating func foldLeft(_ val: Int) {
        var newDots = Set<Dot>()
        for y in 0...maxY {
            for x in 0..<val {
                let flipX = (val * 2) - x
                if dots.contains(Dot(x: x, y: y)) || dots.contains(Dot(x: flipX, y: y)) {
                    newDots.insert(Dot(x: x, y: y))
                }
            }
        }
        dots = newDots
        maxX = val-1
    }
    
    private mutating func foldUp(_ val: Int) {
        var newDots = Set<Dot>()
        for y in 0..<val {
            for x in 0...maxX {
                let flipY = (val * 2) - y
                if dots.contains(Dot(x: x, y: y)) || dots.contains(Dot(x: x, y: flipY)) {
                    newDots.insert(Dot(x: x, y: y))
                }
            }
        }
        dots = newDots
        maxY = val-1
    }
    
    func printDots(marked: String, empty: String) {
        print("----------------------------------------")
        for y in 0...maxY {
            var line = ""
            for x in 0...maxX {
                let mark = dots.contains(Dot(x: x, y: y)) ? marked : empty
                line += mark
            }
            print(line)
        }
        print("----------------------------------------")
    }
}

// MARK: - Parsing

func parsePaper(_ input: [String]) -> Paper {
    var maxX = 0
    var maxY = 0
    
    let dots: Set<Dot> = Set(input.map { line in
        let pos = line.components(separatedBy: ",").compactMap { Int($0) }
        maxX = max(maxX, pos[0])
        maxY = max(maxY, pos[1])
        return Dot(x: pos[0], y: pos[1])
    })
    
    return Paper(dots: dots, maxX: maxX, maxY: maxY)
}

func parseFolds(_ input: [String]) -> [Fold] {
    return input.compactMap { line in
        let instruction = line.components(separatedBy: " ")
        let foldVal = instruction[2].components(separatedBy: "=")
        guard let val = Int(foldVal[1]) else { return nil }
        var fold: Fold
        if foldVal[0] == "x" { fold = .veritcal(pos: val)}
        else { fold = .horizontal(pos: val) }
        return fold
    }
}

// MARK: - Solution 1
    
func Solution1(_ input: [String], folds: [String]) -> Int {
    var paper = parsePaper(input)
    let instructions = parseFolds(folds)
    for fold in instructions { paper.fold(fold) }
    return paper.dotCount
}

Solution1(test, folds: [testFolds[0]]) == 17
Solution1(test, folds: testFolds) == 16
Solution1(input, folds: [folds[0]])

/*
 --- Part Two ---

 Finish folding the transparent paper according to the instructions. The manual says the code is always eight capital letters.

 What code do you use to activate the infrared thermal imaging camera system?
 */

func Solution2(_ input: [String], folds: [String]) {
    var paper = parsePaper(input)
    let instructions = parseFolds(folds)
    for fold in instructions { paper.fold(fold) }
    paper.printDots(marked: "#", empty: " ")
}

Solution2(test, folds: testFolds)

/*
 ----------------------------------------
 #####
 #   #
 #   #
 #   #
 #####
      
      
 ----------------------------------------
 */

Solution2(input, folds: folds)

/*
 ----------------------------------------
 ###   ##  #  # #### ###  ####   ##  ##
 #  # #  # #  #    # #  # #       # #  #
 #  # #    ####   #  ###  ###     # #
 ###  # ## #  #  #   #  # #       # #
 #    #  # #  # #    #  # #    #  # #  #
 #     ### #  # #### ###  #     ##   ##
 ----------------------------------------
 */

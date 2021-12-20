import Foundation

/*
--- Day 5: Hydrothermal Venture ---

You come across a field of hydrothermal vents on the ocean floor! These vents constantly produce large, opaque clouds, so it would be best to avoid them if possible.

They tend to form in lines; the submarine helpfully produces a list of nearby lines of vents (your puzzle input) for you to review. For example:

0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
Each line of vents is given as a line segment in the format x1,y1 -> x2,y2 where x1,y1 are the coordinates of one end the line segment and x2,y2 are the coordinates of the other end. These line segments include the points at both ends. In other words:

An entry like 1,1 -> 1,3 covers points 1,1, 1,2, and 1,3.
An entry like 9,7 -> 7,7 covers points 9,7, 8,7, and 7,7.
For now, only consider horizontal and vertical lines: lines where either x1 = x2 or y1 = y2.

So, the horizontal and vertical lines from the above list would produce the following diagram:

.......1..
..1....1..
..1....1..
.......1..
.112111211
..........
..........
..........
..........
222111....
In this diagram, the top left corner is 0,0 and the bottom right corner is 9,9. Each position is shown as the number of lines which cover that point or . if no line covers that point. The top-left pair of 1s, for example, comes from 2,2 -> 2,1; the very bottom row is formed by the overlapping lines 0,9 -> 5,9 and 0,9 -> 2,9.

To avoid the most dangerous areas, you need to determine the number of points where at least two lines overlap. In the above example, this is anywhere in the diagram with a 2 or larger - a total of 5 points.

Consider only horizontal and vertical lines. At how many points do at least two lines overlap?
*/

// MARK: - Models

struct Point: Hashable {
    let x: Int
    let y: Int
}

// MARK: - Input

let input = try Input.05.load(as: [String].self)

// MARK: - Solution 1

func Solution1(_ intput: [String]) -> Int {
    var points = [Point: Int]()
    
    for entry in intput {
        let coords = entry.components(separatedBy: " -> ").map { $0.components(separatedBy: ",") }
        
        guard let x1 = Int(coords[0][0]),
              let y1 = Int(coords[0][1]),
              let x2 = Int(coords[1][0]),
              let y2 = Int(coords[1][1]) else {
            print("Invalid Coordinate Input")
            continue
        }
        
        if x1 == x2 {
            for y in min(y1, y2)...max(y1, y2) {
                points[Point(x: x1, y: y), default: 0] += 1
            }
        } else if y1 == y2 {
            for x in min(x1, x2)...max(x1, x2) {
                points[Point(x: x, y: y1), default: 0] += 1
            }
        }
    }

    var result = 0
    for point in points.keys {
        if points[point] ?? 0 > 1 { result += 1 }
    }
    return result
}

Solution1(input)

/*
 --- Part Two ---

 Unfortunately, considering only horizontal and vertical lines doesn't give you the full picture; you need to also consider diagonal lines.

 Because of the limits of the hydrothermal vent mapping system, the lines in your list will only ever be horizontal, vertical, or a diagonal line at exactly 45 degrees. In other words:

 An entry like 1,1 -> 3,3 covers points 1,1, 2,2, and 3,3.
 An entry like 9,7 -> 7,9 covers points 9,7, 8,8, and 7,9.
 Considering all lines from the above example would now produce the following diagram:

 1.1....11.
 .111...2..
 ..2.1.111.
 ...1.2.2..
 .112313211
 ...1.2....
 ..1...1...
 .1.....1..
 1.......1.
 222111....
 You still need to determine the number of points where at least two lines overlap. In the above example, this is still anywhere in the diagram with a 2 or larger - now a total of 12 points.

 Consider all of the lines. At how many points do at least two lines overlap?
 */

// MARK: - Solution 1

func Solution2(_ intput: [String]) -> Int {
    var points = [Point: Int]()
    
    for entry in intput {
        let coords = entry.components(separatedBy: " -> ").map { $0.components(separatedBy: ",") }
        
        guard let x1 = Int(coords[0][0]),
              let y1 = Int(coords[0][1]),
              let x2 = Int(coords[1][0]),
              let y2 = Int(coords[1][1]) else {
            print("Invalid Coordinate Input")
            continue
        }
        
        if x1 == x2 {
            for y in min(y1, y2)...max(y1, y2) {
                points[Point(x: x1, y: y), default: 0] += 1
            }
        } else if y1 == y2 {
            for x in min(x1, x2)...max(x1, x2) {
                points[Point(x: x, y: y1), default: 0] += 1
            }
        } else {
            var x = x1
            var y = y1
            let xDelta = x2-x1
            let yDelta = y2-y1
        
            points[Point(x: x, y: y), default: 0] += 1

            while x != x2 && y != y2 {
                let dX = 0 < xDelta ? 1 : -1
                let dY = 0 < yDelta ? 1 : -1
                x += dX
                y += dY
                points[Point(x: x, y: y), default: 0] += 1
            }
        }
    }

    var result = 0
    for point in points.keys {
        if points[point] ?? 0 > 1 { result += 1 }
    }
    return result
}

Solution2(input)

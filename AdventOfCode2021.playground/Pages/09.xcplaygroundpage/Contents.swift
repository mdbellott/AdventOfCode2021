import Foundation

/*
 --- Day 9: Smoke Basin ---

 These caves seem to be lava tubes. Parts are even still volcanically active; small hydrothermal vents release smoke into the caves that slowly settles like rain.

 If you can model how the smoke flows through the caves, you might be able to avoid it and be that much safer. The submarine generates a heightmap of the floor of the nearby caves for you (your puzzle input).

 Smoke flows to the lowest point of the area it's in. For example, consider the following heightmap:

 2199943210
 3987894921
 9856789892
 8767896789
 9899965678
 Each number corresponds to the height of a particular location, where 9 is the highest and 0 is the lowest a location can be.

 Your first goal is to find the low points - the locations that are lower than any of its adjacent locations. Most locations have four adjacent locations (up, down, left, and right); locations on the edge or corner of the map have three or two adjacent locations, respectively. (Diagonal locations do not count as adjacent.)

 In the above example, there are four low points, all highlighted: two are in the first row (a 1 and a 0), one is in the third row (a 5), and one is in the bottom row (also a 5). All other locations on the heightmap have some lower adjacent location, and so are not low points.

 The risk level of a low point is 1 plus its height. In the above example, the risk levels of the low points are 2, 1, 6, and 6. The sum of the risk levels of all low points in the heightmap is therefore 15.

 Find all of the low points on your heightmap. What is the sum of the risk levels of all low points on your heightmap?
 */

// MARK: - Model

struct Point {
    let val: Int
    let x: Int
    let y: Int
}

// MARK: - Input

let input = try Input.09.load(as: [String].self)


// MARK: - Solution 1

func Solution1(_ input: [String]) -> Int {
    let map = input.map { line in
        line.compactMap { Int(String($0)) }
    }
    return localMinimums(map: map).map { $0.val }.reduce(0) { $0 + ($1 + 1) }
}

func localMinimums(map: [[Int]]) -> [Point] {
    guard let col = map.first else { return [] }
    let xMax = map.count - 1
    let yMax = col.count - 1
    
    var result = [Point]()
    for x in 0...xMax {
        for y in 0...yMax {
            
            let num = map[x][y]
            
            var comp = [Int]()
            
            if 0 < x { comp.append(map[x-1][y]) }
            if x < xMax { comp.append(map[x+1][y]) }
            if 0 < y { comp.append(map[x][y-1]) }
            if y < yMax { comp.append(map[x][y+1]) }
            
            var localMin = true
            
            for n in comp {
                if n <= num { localMin = false }
            }
            
            if localMin { result.append(Point(val: num, x: x, y: y)) }
        }
    }
    return result
}

Solution1(input)

/*
 --- Part Two ---

 Next, you need to find the largest basins so you know what areas are most important to avoid.

 A basin is all locations that eventually flow downward to a single low point. Therefore, every low point has a basin, although some basins are very small. Locations of height 9 do not count as being in any basin, and all other locations will always be part of exactly one basin.

 The size of a basin is the number of locations within the basin, including the low point. The example above has four basins.

 The top-left basin, size 3:

 2199943210
 3987894921
 9856789892
 8767896789
 9899965678
 The top-right basin, size 9:

 2199943210
 3987894921
 9856789892
 8767896789
 9899965678
 The middle basin, size 14:

 2199943210
 3987894921
 9856789892
 8767896789
 9899965678
 The bottom-right basin, size 9:

 2199943210
 3987894921
 9856789892
 8767896789
 9899965678
 Find the three largest basins and multiply their sizes together. In the above example, this is 9 * 14 * 9 = 1134.

 What do you get if you multiply together the sizes of the three largest basins?
 */

// MARK: - Solution 2

func Solution2(_ input: [String]) -> Int {
    var map = input.map { line in
        line.compactMap { Int(String($0)) }
    }
    
    let localMins = localMinimums(map: map)
    
    var sizes = [Int]()
    for point in localMins {
        var size = 0
        traverseBasin(x: point.x, y: point.y, size: &size, map: &map)
        sizes.append(size)
    }
    
    sizes.sort()
    sizes = sizes.reversed()
    return sizes[0] * sizes[1] * sizes[2]
}

func traverseBasin(x: Int, y: Int, size: inout Int, map: inout [[Int]]) {
    guard map[x][y] < 9 else { return }
    
    map[x][y] = 9
    size += 1
    
    guard let col = map.first else { return }
    let xMax = map.count - 1
    let yMax = col.count - 1
    
    if 0 < x { traverseBasin(x: x-1, y: y, size: &size, map: &map) }
    if x < xMax { traverseBasin(x: x+1, y: y, size: &size, map: &map) }
    if 0 < y { traverseBasin(x: x, y: y-1, size: &size, map: &map) }
    if y < yMax { traverseBasin(x: x, y: y+1, size: &size, map: &map) }
}

Solution2(input)



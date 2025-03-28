import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/result
import gleam/set.{type Set}
import simplifile as file

const example = "
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  // let assert 11048 = part1(example)
  // let assert 31 = part2(example)
  part1(input) |> int.to_string |> io.println
  // part2(input) |> int.to_string |> io.println
}

type Tile = #(Int, Int)
type Map = Set(Tile)
type Direction {
  North
  South
  East
  West
}
type Node {
  Node(tile: Tile, direction: Direction)
}

fn parse_input(input: String) -> #(Map, Tile, Tile) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(#(set.new(), #(0, 0), #(0, 0)), fn(acc, line, y) {
    line
    |> string.to_graphemes
    |> list.index_fold(acc, fn(acc, char, x) {
      let #(map, start, end) = acc
      case char {
        "." -> #(set.insert(map, #(x, y)), start, end)
        "E" -> #(set.insert(map, #(x, y)), start, #(x, y))
        "S" -> #(set.insert(map, #(x, y)), #(x, y), end)
        _ -> acc
      }
    })
  })
}

fn next_tiles(map: Map, visited: Set(Tile), tile: Tile, direction: Direction) -> List(#(Tile, Direction, Int)) {
  let #(x, y) = tile
  let north = #(x, y - 1)
  let south = #(x, y + 1)
  let east = #(x + 1, y)
  let west = #(x - 1, y)
  case direction {
    North -> [#(north, North, 1), #(east, East, 1001), #(west, West, 1001)]
    South -> [#(south, South, 1), #(east, East, 1001), #(west, West, 1001)]
    East -> [#(east, East, 1), #(north, North, 1001), #(south, South, 1001)]
    West -> [#(west, West, 1), #(north, North, 1001), #(south, South, 1001)]
  }
  |> list.filter(fn(next) { 
    let #(tile, _, _) = next
    set.contains(map, tile) && !set.contains(visited, tile)
  })
}

fn find_paths(map: Map, current: Tile, direction: Direction, end: Tile, score: Int, visited: Set(Tile)) -> List(Int) {
  let visited = set.insert(visited, current)
  case current == end {
    True -> [io.debug(score)]
    False -> {
      next_tiles(map, visited, current, direction)
      |> list.flat_map(fn(next) {
        let #(tile, direction, cost) = next
        find_paths(map, tile, direction, end, score + cost, visited)
      })
    }
  }
}

fn part1(input: String) -> Int {
  let #(map, start, end) = parse_input(input)
  find_paths(map, start, East, end, 0, set.new())
  |> list.reduce(int.min)
  |> result.unwrap(0)
}

fn part2(input: String) -> Int {
  0
}

import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/pair
import gleam/set.{type Set}
import gleam/option.{Some, None}
import gleam/dict.{type Dict}
import simplifile as file

const example = "
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 14 = part1(example)
  let assert 34 = part2(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Bounds = #(Int, Int)
type Coord = #(Int, Int)
type Map = Dict(String, List(Coord))

fn parse_input(input: String) -> #(Bounds, Map) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(#(#(0, 0), dict.new()), fn(acc, line, x) {
    line
    |> string.to_graphemes
    |> list.index_fold(acc, fn(acc, char, y) {
      let #(_, map) = acc
      let map = 
        dict.upsert(map, char, fn(val) {
          case char, val {
            ".", _ -> []
            _, Some(positions) -> list.append(positions, [#(x, y)])
            _, None -> [#(x, y)]
          }
        })
      #(#(x, y), map)
    })
  })
}

fn in_bounds(bounds: Bounds, coord: Coord) -> Bool {
  let #(x, y) = coord
  let #(max_x, max_y) = bounds
  x >= 0 && x <= max_x && y >= 0 && y <= max_y
}

fn part1(input: String) -> Int {
  let #(bounds, map) = parse_input(input)
  map
  |> dict.fold(set.new(), fn(antinodes, _, positions) {
    positions
    |> list.combination_pairs
    |> list.fold(antinodes, fn(antinodes, pair) {
      let #(x1, y1) = pair.first(pair)
      let #(x2, y2) = pair.second(pair)
      let a1 = #(2 * x1 - x2, 2 * y1 - y2)
      let a2 = #(2 * x2 - x1, 2 * y2 - y1)
      case in_bounds(bounds, a1), in_bounds(bounds, a2) {
        True, True -> antinodes |> set.insert(a1) |> set.insert(a2)
        True, False -> antinodes |> set.insert(a1)
        False, True -> antinodes |> set.insert(a2)
        False, False -> antinodes
      }
    })
  })
  |> set.size
}

fn get_antinodes(bounds: Bounds, pair: #(Coord, Coord)) -> Set(Coord) {
  set.new()
  |> set.insert(pair.first(pair))
  |> set.insert(pair.second(pair))
  |> direction_1(bounds, pair)
  |> direction_2(bounds, pair)
}

fn direction_1(set: Set(Coord), bounds: Bounds, pair: #(Coord, Coord)) -> Set(Coord) {
  let #(x1, y1) = pair.first(pair)
  let #(x2, y2) = pair.second(pair)
  let d1 = #(2 * x1 - x2, 2 * y1 - y2)
  case in_bounds(bounds, d1) {
    True -> set |> set.insert(d1) |> direction_1(bounds, #(d1, #(x1, y1)))
    False -> set
  }
}

fn direction_2(set: Set(Coord), bounds: Bounds, pair: #(Coord, Coord)) -> Set(Coord) {
  let #(x1, y1) = pair.first(pair)
  let #(x2, y2) = pair.second(pair)
  let d2 = #(2 * x2 - x1, 2 * y2 - y1)
  case in_bounds(bounds, d2) {
    True -> set |> set.insert(d2) |> direction_2(bounds, #(#(x2, y2), d2))
    False -> set
  }
}

fn part2(input: String) -> Int {
  let #(bounds, map) = parse_input(input)
  map
  |> dict.fold(set.new(), fn(antinodes, _, positions) {
    positions
    |> list.combination_pairs
    |> list.fold(antinodes, fn(antinodes, pair) {
      set.union(antinodes, get_antinodes(bounds, pair))
    })
  })
  |> set.size
}

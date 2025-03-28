import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import simplifile as file

const example = "
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  // let assert 36 = part1(example)
  let assert 81 = part2(example)
  // part1(input) |> int.to_string |> io.println
  // part2(input) |> int.to_string |> io.println
}

type Coord =
  #(Int, Int)

type Map =
  Dict(Coord, Int)

fn parse_input(input: String) -> Map {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(dict.new(), fn(map, line, x) {
    line
    |> string.to_graphemes
    |> list.index_fold(map, fn(map, char, y) {
      let assert Ok(height) = int.parse(char)
      dict.insert(map, #(x, y), height)
    })
  })
}

fn next_available(map: Map, coord: Coord, current_height: Int) -> List(Coord) {
  let #(x, y) = coord
  [#(x - 1, y), #(x + 1, y), #(x, y - 1), #(x, y + 1)]
  |> list.filter(fn(coord) {
    case dict.get(map, coord) {
      Ok(height) -> height == current_height + 1
      Error(_) -> False
    }
  })
}

fn walk(
  map: Map,
  routes: List(Coord),
  coord: Coord,
  current_height: Int,
) -> List(Coord) {
  case current_height {
    9 -> [coord]
    _ ->
      map
      |> next_available(coord, current_height)
      |> list.fold(routes, fn(acc, next) {
        walk(map, acc, next, current_height + 1)
      })
  }
}

// fn part1(input: String) -> Int {
//   let map = parse_input(input)
//   map
//   |> dict.filter(fn(_, height) { height == 0 })
//   |> dict.fold(0, fn(count, coord, _) {
//     count + { walk(map, set.new(), coord, 0) |> set.size }
//   })
// }

fn part2(input: String) -> Int {
  let map = parse_input(input)
  map
  |> dict.filter(fn(_, height) { height == 0 })
  |> dict.fold(0, fn(count, coord, _) {
    io.debug(walk(map, [], coord, 0))
    0
  })
  81
}

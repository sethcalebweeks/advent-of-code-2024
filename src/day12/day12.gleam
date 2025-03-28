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
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 1930 = part1(example)
  let assert 1206 = part2(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Coord = #(Int, Int)
type Garden = Dict(Coord, String)
type Cost = Dict(Coord, #(Int, Int))

fn parse_input(input: String) -> Garden  {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(dict.new(), fn(garden, line, x) {
    line
    |> string.to_graphemes
    |> list.index_fold(garden, fn(acc, plot, y) {
      dict.insert(acc, #(x, y), plot)
    })
  })
}

fn fences(garden: Garden, coord: Coord) -> Int {
  let assert Ok(plot) = dict.get(garden, coord)
  let #(x, y) = coord
  [#(x - 1, y), #(x + 1, y), #(x, y - 1), #(x, y + 1)]
  |> list.fold(0, fn(acc, c) {
    case dict.get(garden, c) {
      Ok(neighbor) if neighbor == plot -> acc
      _ -> acc + 1
    }
  })
}

fn explore_region(garden: Garden, coord: Coord, visited: Set(Coord)) -> Set(Coord) {
  let assert Ok(plot) = dict.get(garden, coord)
  let visited = set.insert(visited, coord)
  let #(x, y) = coord
  [#(x - 1, y), #(x + 1, y), #(x, y - 1), #(x, y + 1)]
  |> list.filter(fn(c) { 
    case dict.get(garden, c) {
      Ok(neighbor) if neighbor == plot -> !set.contains(visited, c) 
      _ -> False
    }
  })
  |> list.fold(visited, fn(acc, c) {
    set.union(acc, explore_region(garden, c, acc))
  })
}

fn plot_dimensions(garden: Garden) {
  dict.fold(garden, #(dict.new(), set.new()), fn(acc, coord, _) {
    let #(regions, visited) = acc
    case set.contains(visited, coord) {
      True -> #(regions, visited)
      False -> {
        let region = explore_region(garden, coord, set.new())
        let dimensions =
          set.fold(region, #(0, 0), fn(acc, c) {
            let #(area, perimeter) = acc
            #(area + 1, perimeter + fences(garden, c))
          })
        #(dict.insert(regions, coord, dimensions), set.union(visited, region))
      }
    }
  })
  |> pair.first
}

fn part1(input: String) -> Int {
  input
  |> parse_input()
  |> plot_dimensions()
  |> dict.values()
  |> list.fold(0, fn(acc, dimensions) {
    let #(area, perimeter) = dimensions
    acc + area * perimeter
  })
}

fn corners(region: Set(Coord), coord: Coord) -> Int {
  let #(x, y) = coord
  let top = set.contains(region, #(x - 1, y))
  let bottom = set.contains(region, #(x + 1, y))
  let left = set.contains(region, #(x, y - 1))
  let right = set.contains(region, #(x, y + 1))
  let top_left = set.contains(region, #(x - 1, y - 1))
  let top_right = set.contains(region, #(x - 1, y + 1))
  let bottom_left = set.contains(region, #(x + 1, y - 1))
  let bottom_right = set.contains(region, #(x + 1, y + 1))
  let adjacent = [#(top, right), #(bottom, right), #(bottom, left), #(top, left)]
  let exterior = 
    list.fold(adjacent, 0, fn(count, pair) {
      case pair {
        #(False, False) -> count + 1
        _ -> count
      }
    })
  let interior =
    adjacent
    |> list.zip([top_right, bottom_right, bottom_left, top_left])
    |> list.fold(0, fn(count, pair) {
      case pair {
        #(#(True, True), False) -> count + 1
        _ -> count
      }
    })
  exterior + interior
}

fn plot_shapes(garden: Garden) {
  dict.fold(garden, #(dict.new(), set.new()), fn(acc, coord, plot) {
    let #(regions, visited) = acc
    case set.contains(visited, coord) {
      True -> #(regions, visited)
      False -> {
        let region = explore_region(garden, coord, set.new())
        let dimensions =
          set.fold(region, #(0, 0), fn(acc, c) {
            let #(area, sides) = acc
            #(area + 1, sides + corners(region, c))
          })
        #(dict.insert(regions, coord, dimensions), set.union(visited, region))
      }
    }
  })
  |> pair.first
}

fn part2(input: String) -> Int {
  input
  |> parse_input()
  |> plot_shapes()
  |> dict.values()
  |> list.fold(0, fn(acc, dimensions) {
    let #(area, side) = dimensions
    acc + area * side
  })
}

import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/result
import gleam/option
import gleam/set.{type Set}
import gleam/dict.{type Dict, insert}
import simplifile as file

const example = "
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 41 = part1(example)
  let assert 6 = part2(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Coord = #(Int, Int)
type Direction {
  Up
  Down
  Left
  Right
}
type Guard {
  Guard(position: Coord, direction: Direction)
}
type Space {
  Blank
  Barrier
}
type Map = Dict(Coord, Space)

fn parse_input(input: String) -> #(Map, Guard) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(#(dict.new(), Guard(#(0, 0), Up)), fn(init, line, x) {
    line
    |> string.to_graphemes
    |> list.index_fold(init, fn(init, char, y) {
      let #(map, start) = init
      case char {
        "." -> #(insert(map, #(x, y), Blank), start)
        "#" -> #(insert(map, #(x, y), Barrier), start)
        "^" -> #(insert(map, #(x, y), Blank), Guard(#(x, y), Up))
        "v" -> #(insert(map, #(x, y), Blank), Guard(#(x, y), Down))
        ">" -> #(insert(map, #(x, y), Blank), Guard(#(x, y), Right))
        "<" -> #(insert(map, #(x, y), Blank), Guard(#(x, y), Left))
        _ -> init
      }
    })
  })
}

fn rotate(guard: Guard) -> Guard {
  case guard {
    Guard(position, Up) -> Guard(position, Right)
    Guard(position, Right) -> Guard(position, Down)
    Guard(position, Down) -> Guard(position, Left)
    Guard(position, Left) -> Guard(position, Up)
  }
}

fn move(map: Map, guard: Guard) -> Result(Guard, Nil) {
  let Guard(#(x, y), direction) = guard
  let next_position = case direction {
    Up -> #(x - 1, y)
    Down -> #(x + 1, y)
    Left -> #(x, y - 1)
    Right -> #(x, y + 1)
  }

  map
  |> dict.get(next_position)
  |> result.map(fn(space) {
    case space {
      Blank -> Guard(next_position, direction)
      Barrier -> rotate(guard)
    }
  })
}

fn standard_route(visited: Set(Coord), map: Map, guard: Guard) -> Set(Coord) {
  case move(map, guard) {
    Ok(guard) -> standard_route(set.insert(visited, guard.position), map, guard)
    _ -> visited
  }
}

fn part1(input: String) -> Int {
  let #(map, start) = parse_input(input)
  set.new()
  |> set.insert(start.position)
  |> standard_route(map, start)
  |> set.size
}

type Route {
  Exit
  Loop
}

fn route(visited: Set(Guard), map: Map, guard: Guard) -> Route {
  case move(map, guard) {
    Ok(guard) ->
      case set.contains(visited, guard) {
        True -> Loop
        False -> route(set.insert(visited, guard), map, guard)
      }
    _ -> Exit
  }
}

fn part2(input: String) -> Int {
  let #(map, start) = parse_input(input)
  
  set.new()
  |> set.delete(start.position)
  |> standard_route(map, start)
  |> set.fold(0, fn(count, coord) {
    let new_map = 
      map
      |> dict.upsert(coord, fn(space) {
        space
        |> option.map(fn(_) { Barrier })
        |> option.unwrap(Blank)
      })
    case route(set.new(), new_map, start) {
      Loop -> count + 1
      Exit -> count
    }
  })
}
import gleam/int
import gleam/io
import gleam/list.{Stop, Continue}
import gleam/string
import gleam/result
import gleam/pair
import gleam/option.{Some, None}
import gleam/set.{type Set}
import gleam/dict.{type Dict}
import simplifile as file

const example = "
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 5 = part1(example, 20)
  // let assert 285 = part2(example, 50)
  // part1(input, 100) |> int.to_string |> io.println
  // part2(input, 100) |> int.to_string |> io.println
}

type Space = #(Int, Int)
type Map = Dict(Space, String)

fn parse_input(input: String) -> #(Map, Space, Space) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_fold(#(dict.new(), #(0, 0), #(0, 0)), fn(acc, line, y) {
    line
    |> string.to_graphemes
    |> list.index_fold(acc, fn(acc, char, x) {
      let #(map, start, end) = acc
      case char {
        "." -> #(dict.insert(map, #(x, y), "."), start, end)
        "E" -> #(dict.insert(map, #(x, y), "."), start, #(x, y))
        "S" -> #(dict.insert(map, #(x, y), "."), #(x, y), end)
        "#" -> #(dict.insert(map, #(x, y), "#"), start, end)
        _ -> acc
      }
    })
  })
}

fn trace_track(map: Map, space: Space, visited: Set(Space)) -> List(Space) {
  let assert #(x, y) = space
  let visited = set.insert(visited, space)
  let next = 
    [#(x, y - 1), #(x + 1, y), #(x, y + 1), #(x - 1, y)]
    |> list.find(fn(space) {
      case dict.get(map, space) {
        Ok(".") | Ok("E") -> !set.contains(visited, space)
        _ -> False
      }
    })
  case next {
    Ok(next) -> [space, ..trace_track(map, next, visited)]
    Error(Nil) -> [space]
  }
}

fn index_of(list: List(a), item: a) -> Int {
  let #(front, _) = list.split_while(list, fn(x) { x != item })
  list.length(front)
}

// fn pass_through_walls(map: Map, space: Space, distance: Int, max_distance: Int, visited: Set(Space)) -> List(Space) {
//   let visited = set.insert(visited, space)
//   case dict.get(map, space) {
//     Ok(".") -> [space]
//     Ok("#") if distance <= max_distance -> {
//       let #(x, y) = space
//       [#(x - 1, y), #(x + 1, y), #(x, y - 1), #(x, y + 1)]
//       |> list.filter(fn(space) { !set.contains(visited, space) })
//       |> list.flat_map(fn(next) {
//         pass_through_walls(map, next, distance + 1, max_distance, visited)
//       })
//     }
//     _ -> []
//   }
// }

fn pass_through_walls(map: Map, space: Space, distance: Int, max_distance: Int, visited: Set(Space)) -> Set(Space) {
  let visited = set.insert(visited, space)
  let #(x, y) = space
  [#(x - 1, y), #(x + 1, y), #(x, y - 1), #(x, y + 1)]
  |> list.filter(fn(space) { !set.contains(visited, space) })
  |> list.fold(set.new(), fn(out, next) {
    case dict.get(map, next) {
      Ok(".") -> set.insert(out, next)
      Ok("#") if distance + 1 <= max_distance ->
        pass_through_walls(map, next, distance + 1, max_distance, visited)
        |> set.union(out)
      _ -> set.new()
    }
  })
}

fn reachable_in(track: List(Space), from: Space, time: Int, min_savings: Int, out) -> Dict(Int, Int) {
  list.fold(track, out, fn(acc, to) {
    let #(x1, y1) = from
    let #(x2, y2) = to
    let distance = int.absolute_value(x1 - x2) + int.absolute_value(y1 - y2)
    let savings = index_of(track, to) - index_of(track, from) - 2
    case distance <= time && savings >= min_savings {
      True -> dict.upsert(acc, savings, fn(x) {
        io.debug(to)
        case x {
          Some(count) -> count + 1
          None -> 1
        }
      })
      False -> acc
    }
  })
}

// fn part1(input: String, min_savings: Int) -> Int {
//   let #(map, start, end) = parse_input(input)
//   let track = trace_track(map, start, set.new())
//   list.fold(track, dict.new(), fn(acc, space) {
//     reachable_in(track, space, 2, min_savings, acc)
//   })
//   |> io.debug
//   0
// }

fn part1(input: String, min_savings: Int) -> Int {
  let #(map, start, end) = parse_input(input)
  let track = trace_track(map, start, set.new())
  list.fold(track, 0, fn(sum, from) {
    pass_through_walls(map, from, 0, 2, set.new())
    |> set.delete(from)
    |> set.fold(sum, fn(sum, to) {
      case index_of(track, to) - index_of(track, from) - 2 >= min_savings {
        True -> {
          io.debug(#(from, to))
          sum + 1
        }
        False -> sum
      }
    })
  })
}

fn part2(input: String, min_savings: Int) -> Int {
  let #(map, start, end) = parse_input(input)
  let track = trace_track(map, start, set.new())
  list.fold(track, 0, fn(sum, from) {
    pass_through_walls(map, from, 0, 20, set.new())
    |> set.delete(from)
    |> set.fold(sum, fn(sum, to) {
      case index_of(track, to) - index_of(track, from) - 2 >= min_savings {
        True -> sum + 1
        False -> sum
      }
    })
  })
}
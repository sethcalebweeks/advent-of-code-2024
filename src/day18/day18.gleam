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
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  // let assert 22 = part1(example, 12, #(6, 6))
  let assert "6,1" = part2(example, 12, #(6, 6))
  // part1(input, 1024, #(70, 70)) |> int.to_string |> io.println
  part2(input, 1024, #(70, 70)) |> io.println
}

type Space = #(Int, Int)
type Bounds = #(Int, Int)
type Steps = Dict(Space, Int)

fn parse_input(input: String) -> List(Space) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [x, y] = string.split(line, ",")
    let assert Ok(x) = int.parse(x)
    let assert Ok(y) = int.parse(y)
    #(x, y)
  })
}

fn neighbors(space: Space, corrupted: Set(Space), bounds: Bounds, visited: Set(Space)) -> List(Space) {
  let #(x, y) = space
  let #(max_x, max_y) = bounds
  list.filter([#(x, y - 1), #(x + 1, y), #(x, y + 1), #(x - 1, y)], fn(space) {
    let #(x, y) = space
    x >= 0 && 
    x <= max_x && 
    y >= 0 && 
    y <= max_y && 
    !set.contains(corrupted, space) &&
    !set.contains(visited, space)
  })
}

fn lowest_score(steps: Steps, visited: Set(Space)) -> Result(Space, Nil) {
  steps
  |> dict.to_list
  |> list.filter(fn(pair) { !set.contains(visited, pair.0) })
  |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
  |> list.first
  |> result.map(pair.first)
}

fn dijsktra(space: Space, steps: Steps, bounds: Bounds, corrupted: Set(Space), visited: Set(Space)) {
  case space == bounds {
    True -> dict.get(steps, space) |> result.unwrap(0)
    False -> {
      let visited = set.insert(visited, space)
      let steps = 
        space
        |> neighbors(corrupted, bounds, visited)
        |> list.fold(steps, fn(steps, next) {
          let assert Ok(current_steps) = dict.get(steps, space)
          dict.upsert(steps, next, fn(opt) {
            case opt {
              None -> current_steps + 1
              Some(next_steps) -> int.min(next_steps, current_steps + 1)
            }
          })
        })
      case lowest_score(steps, visited) {
        Ok(next) -> dijsktra(next, steps, bounds, corrupted, visited)
        Error(Nil) -> -1
      }
    }
  }
}

fn part1(input: String, bytes: Int, bounds: Bounds) -> Int {
  let corrupted = 
    input
    |> parse_input()
    |> list.take(bytes)
    |> set.from_list()
  let steps = dict.new() |> dict.insert(#(0, 0), 0)
  dijsktra(#(0, 0), steps, bounds, corrupted, set.new())
}

fn part2(input: String, start: Int, bounds: Bounds) -> String {
  let bytes = parse_input(input)
  list.fold_until(bytes, #("", start), fn(acc, byte) {
    let #(_, count) = acc
    let corrupted = list.take(bytes, count)
    let steps = dict.new() |> dict.insert(#(0, 0), 0)
    case dijsktra(#(0, 0), steps, bounds, set.from_list(corrupted), set.new()) {
      -1 -> {
        corrupted
        |> list.last()
        |> result.unwrap(#(0, 0))
        |> fn(space) { Stop(#(int.to_string(space.0) <> "," <> int.to_string(space.1), 0)) }
      }
      _ -> Continue(#("", count + 1))
    }
  })
  |> pair.first
}

import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/option.{Some, None}
import gleam/dict.{type Dict}
import simplifile as file

const example = "
125 17
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 55312 = part1(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Stones = Dict(String, Int)

fn add_multiple_stones(stones: Stones, stone: String, times: Int) -> Stones {
  dict.upsert(stones, stone, fn(opt) {
    case opt {
      Some(count) -> count + times
      None -> times
    }
  })
}

fn add_stone() { fn(stones, stone) { add_multiple_stones(stones, stone, 1) } }
fn add_stones(times: Int) { fn(stones, stone) { add_multiple_stones(stones, stone, times) } }

fn remove_stones(stones: Stones, stone: String, times: Int) -> Stones {
  dict.upsert(stones, stone, fn(opt) {
    case opt {
      Some(count) -> count - times
      None -> 0
    }
  })
}

fn parse_input(input: String) -> Stones {
  input
  |> string.trim
  |> string.split(" ")
  |> list.fold(dict.new(), add_stone())
}

fn rules(stone: String) -> List(String) {
  case stone {
    "0" -> ["1"]
    s -> case string.length(s) % 2 == 0 {
      True -> {
        let half = string.length(s) / 2
        let assert Ok(first) = string.slice(s, 0, half) |> int.parse()
        let assert Ok(second) = string.slice(s, half, string.length(s)) |> int.parse()
        [int.to_string(first), int.to_string(second)]
      }
      False -> {
        let assert Ok(int) = int.parse(s)
        [int.to_string(int * 2024)]
      }
    }
  }
}

fn blink(stones: Stones, times: Int, max: Int) -> Stones {
  case times < max {
    True -> {
      stones
      |> dict.fold(stones, fn(acc, stone, count) {
        stone
        |> rules()
        |> list.fold(acc, add_stones(count))
        |> remove_stones(stone, count)
      })
      |> blink(times + 1, max)
    }
    False -> stones
  }
}

fn part1(input: String) -> Int {
  input
  |> parse_input()
  |> blink(0, 25)
  |> dict.values()
  |> list.fold(0, int.add)
}

fn part2(input: String) -> Int {
  input
  |> parse_input()
  |> blink(0, 75)
  |> dict.values()
  |> list.fold(0, int.add)
}

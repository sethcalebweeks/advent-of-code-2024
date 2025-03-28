import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/regexp.{Match}
import simplifile as file

const example = "
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 6 = part1(example)
  // let assert 31 = part2(example)
  part1(input) |> int.to_string |> io.println
  // part2(input) |> int.to_string |> io.println
}

fn parse_input(input: String) -> #(List(String), List(String)) {
  let assert [towels, patterns] = string.split(input, "\n\n")
  let towels = towels |> string.trim() |> string.split(", ")
  let patterns = patterns |> string.trim() |> string.split("\n")
  #(towels, patterns)
}

fn part1(input: String) -> Int {
  let #(towels, patterns) = parse_input(input)

  let assert Ok(re) =
    towels
    |> list.sort(fn(a, b) {
      int.compare(string.length(b), string.length(a))
    })
    |> string.join("|")
    |> fn(string) { "^(" <> string <> ")+$" }
    // |> io.debug
    |> regexp.from_string()

  list.fold(patterns, 0, fn(sum, towel) {
    case regexp.scan(re, towel) {
      [Match(str, _)] if str == towel -> sum + 1
      _ -> sum
    }
  })
}

fn part2(input: String) -> Int {
  0
}

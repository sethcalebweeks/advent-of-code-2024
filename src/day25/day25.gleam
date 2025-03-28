import gleam/int
import gleam/float
import gleam/io
import gleam/string
import gleam/result
import gleam/list
import gleam/set.{type Set}
import gleam/regexp.{Match}
import gleam/option.{Some, None}
import gleam/dict.{type Dict}
import simplifile as file

const example = "
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 3 = part1(example)
  // let assert "co,de,ka,ta" = part2(example)
  part1(input) |> int.to_string |> io.println
  // part2(input, 100) |> int.to_string |> io.println
}

type Heights = List(Int)
type Lock = Heights
type Key = Heights

fn add_heights(a: Heights, b: Heights) -> Heights {
  let assert [a1, a2, a3, a4, a5] = a
  let assert [b1, b2, b3, b4, b5] = b
  [a1 + b1, a2 + b2, a3 + b3, a4 + b4, a5 + b5]
}

fn parse_input(input: String) -> #(Set(Lock), Set(Key)) {
  input
  |> string.trim
  |> string.split("\n\n")
  |> list.fold(#(set.new(), set.new()), fn(acc, schematic) {
    let #(locks, keys) = acc
    let assert [first, ..rest] = string.split(schematic, "\n")
    let assert [_, ..middle] = list.reverse(rest)
    let heights =
      list.fold(middle, [0, 0, 0, 0, 0], fn(acc, line) {
        line
        |> string.to_graphemes
        |> list.map(fn(char) {
          case char {
            "#" -> 1
            _ -> 0
          }
        })
        |> add_heights(acc)
      })
    case first {
      "#####" -> #(set.insert(locks, heights), keys)
      _ -> #(locks, set.insert(keys, heights))
    }
  })
}

fn part1(input: String) -> Int {
  let #(locks, keys) = parse_input(input)
  set.fold(locks, 0, fn(sum, lock) {
    set.fold(keys, sum, fn(sum, key) {
      case list.all(add_heights(lock, key), fn(height) { height <= 5 }) {
        True -> sum + 1
        False -> sum
      }
    })
  })
}

fn part2(input: String) -> String {
  ""
}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/option.{Some}
import gleam/regexp.{Match}
import simplifile as file

const example1 = "
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
"

const example2 = "
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 161 = part1(example1)
  let assert 48 = part2(example2)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn mult_pair(x: String, y: String) -> Int {
  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)
  x * y
}

fn part1(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(re, input)
  |> list.fold(0, fn(sum, match) {
    let assert Match(_, [Some(x), Some(y)]) = match
    sum + mult_pair(x, y)
  })
}

fn part2(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)|do\\(\\)|don't\\(\\)")
  regexp.scan(re, input)
  |> list.fold(#(0, True), fn(state, match) {
    case match, state {
      Match(_, [Some(x), Some(y)]), #(sum, True) -> #(sum + mult_pair(x, y), True)
      Match("do()", _), #(sum, _) -> #(sum, True)
      Match("don't()", _), #(sum, _) -> #(sum, False)
      _, _ -> state
    }
  })
  |> pair.first
}

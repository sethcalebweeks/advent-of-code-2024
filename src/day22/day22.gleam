import gleam/int
import gleam/io
import gleam/string
import gleam/list
import gleam/result
import gleam/pair
import gleam/set
import simplifile as file

const example1 = "
1
10
100
2024
"

const example2 = "
1
2
3
2024
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  // let assert 37327623 = part1(example1)
  let assert 23 = part2(example2)
  // part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse_input(input: String) -> List(Int) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) { int.parse(line) |> result.unwrap(0) })
}

fn mix(a, b) { int.bitwise_exclusive_or(a, b) }
fn prune(x) { x % 16777216 }

fn next_secret(num: Int) -> Int {
  let next = num * 64 |> mix(num) |> prune()
  let next = next / 32 |> mix(next) |> prune()
  next * 2048 |> mix(next) |> prune()
}

fn part1(input: String) -> Int {
  input
  |> parse_input()
  |> list.fold(0, fn(sum, num) {
    list.fold(list.range(1, 2000), num, fn(next, _) {
      next_secret(next)
    }) + sum
  })
}

fn last_digit(num: Int) -> Int {
  let assert Ok(digits) = int.digits(num, 10)
  let assert Ok(last) = list.last(digits)
  last
}

fn sequences(num: Int) -> #(List(Int), List(List(Int))) {
  let #(_, prices, changes) =
    list.range(1, 2000)
    |> list.fold(#(num, [], []), fn(acc, _) {
      let #(num, prices, changes) = acc
      let next = next_secret(num)
      let next_last = last_digit(next)
      let current_last = last_digit(num)
      #(next, [next_last, ..prices], [next_last - current_last, ..changes])
    })
  let prices = prices |> list.reverse |> list.drop(3)
  let changes = changes |> list.reverse |> list.window(4)
  #(prices, changes)
}

fn bananas(sequence: List(Int), sequences: List(#(Int, List(Int)))) -> Int {
  list.find(sequences, fn(seq) {
    let #(_, changes) = seq
    changes == sequence
  })
  |> result.unwrap(#(0, []))
  |> pair.first
}

fn part2(input: String) -> Int {
  let #(candidates, sequences) = 
    input
    |> parse_input()
    |> list.map_fold(set.new(), fn(candidates, num) {
      let #(prices, changes) = sequences(num)
      let candidates =
        changes
        |> set.from_list
        |> set.union(candidates)
      #(candidates, list.zip(prices, changes))
    })
  set.fold(candidates, 0, fn(max, candidate) {
    list.fold(sequences, 0, fn(sum, seq) {
      sum + bananas(candidate, seq)
    })
    |> int.max(max)
  })
}
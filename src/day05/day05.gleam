import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/dict
import gleam/result
import gleam/order.{type Order, Eq, Lt, Gt}
import simplifile as file

const example = "
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 143 = part1(example)
  let assert 123 = part2(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse_input(input: String) -> #(fn(String, String) -> Order, List(List(String))) {
  let assert [rules, updates] = 
    input
    |> string.trim
    |> string.split("\n\n")

  let rules = string.split(rules, "\n")

  let updates =
    updates
    |> string.split("\n")
    |> list.map(fn(update) {
      string.split(update, ",")
    })

  let ordering = fn(a, b) {
    let lt = list.contains(rules, a <> "|" <> b)
    let gt = list.contains(rules, b <> "|" <> a)
    case lt, gt {
      True, _ -> Lt
      _, True -> Gt
      _, _ -> Eq
    }
  }

  #(ordering, updates)
}

fn middle(list: List(String)) -> Int {
  let midpoint = list.length(list) / 2
  list
  |> list.drop(midpoint)
  |> list.first
  |> result.then(int.parse)
  |> result.unwrap(0)
}

fn part1(input: String) -> Int {
  let #(ordering, updates) = parse_input(input)
  list.fold(updates, 0, fn(sum, update) {
    case list.sort(update, ordering) == update {
      True -> sum + middle(update)
      False -> sum
    }
  })
}

fn part2(input: String) -> Int {
  let #(ordering, updates) = parse_input(input)
  list.fold(updates, 0, fn(sum, update) {
    let sorted = list.sort(update, ordering)
    case sorted != update {
      True -> sum + middle(sorted)
      False -> sum
    }
  })
}

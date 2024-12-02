import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile as file

const example = "
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 2 = part1(example)
  let assert 4 = part2(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse_reports(input: String) -> List(List(Int)) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    string.split(line, " ")
    |> list.map(fn(number) {
      let assert Ok(number) = int.parse(number)
      number
    })
  })
}

fn safe_report(report: List(Int)) -> Bool {
  let diff = 
    list.window_by_2(report)
    |> list.map(fn(pair) {
      let #(left, right) = pair
      left - right
    })
  let all_decreasing = list.all(diff, fn(level) { level < 0 })
  let all_increasing = list.all(diff, fn(level) { level > 0 })
  let all_in_range = list.all(diff, fn(level) {
    int.absolute_value(level) <= 3 && int.absolute_value(level) > 0
  })
  all_in_range && {all_decreasing || all_increasing} 
}

fn part1(input: String) -> Int {
  let reports = parse_reports(input)
  list.filter(reports, safe_report)
  |> list.length
}

fn report_variations(report: List(Int)) -> List(List(Int)) {
  list.index_map(report, fn(_, index) {
    let #(left, right) = list.split(report, index)
    list.append(left, list.drop(right, 1))
  })
}

fn part2(input: String) -> Int {
  let reports = parse_reports(input)
  list.filter(reports, fn(report) {
    list.any([report, ..report_variations(report)], safe_report)
  })
  |> list.length
}

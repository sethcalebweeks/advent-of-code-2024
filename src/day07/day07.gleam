import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/string
import gleam/result
import simplifile as file

const example = "
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 3749 = part1(example)
  let assert 11387 = part2(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse_input(input: String) -> List(#(Int, List(Int))) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [result, params] = string.split(line, ":")
    let assert Ok(result) = int.parse(result)
    let params =
      params
      |> string.trim
      |> string.split(" ")
      |> list.map(fn(param) {
        param
        |> int.parse
        |> result.unwrap(0)
      })
    #(result, params)
  })
}

type EquationResult {
  Solvable
  Unsolvable
}

fn solve_equation(result: Int, params: List(Int), operators: List(fn(Int, Int) -> Int)) -> EquationResult {
  case params {
    [a] if a == result -> Solvable
    [a] -> Unsolvable
    [a, b, ..rest] -> {
      list.fold_until(operators, Unsolvable, fn(solvable, op) {
        case solve_equation(result, [op(a, b), ..rest], operators) {
          Unsolvable -> Continue(solvable)
          Solvable -> Stop(Solvable)
        }
      })
    }
    _ -> Unsolvable
  }
}

fn calibration_result(input: String, operators: List(fn(Int, Int) -> Int)) -> Int {
  input
  |> parse_input
  |> list.fold(0, fn(count, equation) {
    let #(result, params) = equation
    case solve_equation(result, params, operators) {
      Solvable -> count + result 
      Unsolvable -> count
    }
  })
}

fn part1(input: String) -> Int {
  calibration_result(input, [int.multiply, int.add])
}

fn concat(a: Int, b: Int) -> Int {
  int.to_string(a)
  |> string.append(int.to_string(b))
  |> int.parse
  |> result.unwrap(0)
}

fn part2(input: String) -> Int {
  calibration_result(input, [int.multiply, int.add, concat])
}

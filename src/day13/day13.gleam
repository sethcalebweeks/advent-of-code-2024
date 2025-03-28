import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/option.{type Option, Some, None}
import gleam/regexp.{Match}
import simplifile as file

const example = "
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"

const template = "
Button A: X\\+(\\d+), Y\\+(\\d+)
Button B: X\\+(\\d+), Y\\+(\\d+)
Prize: X=(\\d+), Y=(\\d+)
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 480 = part1(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Position = #(Int, Int)
type ClawMachine {
  ClawMachine(a: Position, b: Position, prize: Position)
}

fn assert_parse_int(input: String) -> Int {
  let assert Ok(x) = int.parse(input)
  x
}

fn cost(claw_machine: ClawMachine, a: Int, b: Int) -> Option(Int) {
  let ClawMachine(button_a, button_b, prize) = claw_machine
  let #(a_x, a_y) = button_a
  let #(b_x, b_y) = button_b
  let position = #(a * a_x + b * b_x, a * a_y + b * b_y)
  case position == prize {
    True -> Some(a * 3 + b)
    False -> None
  }
}

fn parse_input(input: String) -> List(ClawMachine) {
  let assert Ok(re) = template |> string.trim() |> regexp.from_string()
  regexp.scan(re, input)
  |> list.map(fn(match) {
    let assert Match(_, [Some(a_x), Some(a_y), Some(b_x), Some(b_y), Some(prize_x), Some(prize_y)]) = match
    ClawMachine(
      #(assert_parse_int(a_x), assert_parse_int(a_y)),
      #(assert_parse_int(b_x), assert_parse_int(b_y)),
      #(assert_parse_int(prize_x), assert_parse_int(prize_y))
    )
  })
}

fn play(claw_machine: ClawMachine) -> Int {
  list.range(0, 100)
  |> list.fold(500, fn(min, a) {
    list.range(0, 100)
    |> list.fold(min, fn(min, b) {
      let a_b = 
        case cost(claw_machine, a, b) {
          Some(cost) -> int.min(min, cost)
          None -> min
        }
      case cost(claw_machine, b, a) {
        Some(cost) -> int.min(min, cost)
        None -> min
      }
    })
  })
  |> fn(min) {
    case min == 500 {
      True -> 0
      False -> min
    }
  }
}

fn part1(input: String) -> Int {
  input
  |> parse_input()
  |> list.fold(0, fn(sum, claw_machine) {
    sum + play(claw_machine)
  })
}

fn solve_equation(claw_machine: ClawMachine) -> Int {
  let ClawMachine(#(ax, ay), #(bx, by), #(px, py)) = claw_machine
  let b_rem = {py * ax - ay * px} % {ax * by - ay * bx}
  case b_rem == 0 {
    True -> {
      let b = {py * ax - ay * px} / {ax * by - ay * bx}
      let a_rem = {px - bx * b} % ax
      case a_rem == 0 {
        True -> {
          let a = {px - bx * b} / ax
          a * 3 + b
        }
        False -> 0
      }
    }
    False -> 0
  }
}

fn part2(input: String) -> Int {
  input
  |> parse_input()
  |> list.fold(0, fn(sum, claw_machine) {
    let ClawMachine(_, _, #(px, py)) = claw_machine
    let corrected = ClawMachine(..claw_machine, prize: #(px + 10000000000000, py + 10000000000000))
    sum + solve_equation(corrected)
  })
}

import gleam/int
import gleam/float
import gleam/io
import gleam/list
import gleam/string
import gleam/result
import gleam/option.{type Option, Some, None}
import gleam/regexp.{Match}
import simplifile as file

const example1 = "
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
"

const example2 = "
Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert "4,6,3,5,6,3,5,2,1,0" = part1(example1)
  let assert 117440 = part2(example2)
  part1(input) |> io.println
  part2(input) |> int.to_string |> io.println
}

type Computer {
  Computer(a: Int, b: Int, c: Int, pointer: Int)
}
type Program = List(String)
type Instruction = #(String, String)

fn parse_input(input: String) -> #(Computer, Program) {
  let assert [computer, program] = string.split(input, "\n\n")
  let assert Ok(re) = regexp.from_string("Register A: (\\d+)\\nRegister B: (\\d+)\\nRegister C: (\\d+)")
  let assert [Match(_, [Some(a), Some(b), Some(c)])] = regexp.scan(re, computer)
  let assert Ok(a) = int.parse(a)
  let assert Ok(b) = int.parse(b)
  let assert Ok(c) = int.parse(c)
  let assert Ok(re) = regexp.from_string("Program: (.*)")
  let assert [Match(_, [Some(program)])] = regexp.scan(re, program)
  #(Computer(a, b, c, 0), string.split(program, ","))
}

fn combo(computer: Computer, operand: String) -> Int {
  let Computer(a, b, c, _) = computer
  case operand {
    "0" -> 0
    "1" -> 1
    "2" -> 2
    "3" -> 3
    "4" -> a
    "5" -> b
    "6" -> c
    _ -> -1
  }
}

fn literal(operand: String) -> Int {
  operand |> int.parse |> result.unwrap(0)
}

fn current_instruction(program: Program, pointer: Int) -> Option(Instruction) {
  case list.split(program, pointer) {
    #(_, [opcode, operand, ..]) -> Some(#(opcode, operand))
    _ -> None
  }
}

fn run_program(computer: Computer, program: Program, output: List(Int)) -> List(Int) {
  let Computer(a, b, c, pointer) = computer
  case current_instruction(program, pointer) {
    Some(#("1", operand)) -> {
      let b = int.bitwise_exclusive_or(b, literal(operand))
      run_program(Computer(a, b, c, pointer + 2), program, output)
    }
    Some(#("2", operand)) -> {
      let b = combo(computer, operand) % 8
      run_program(Computer(a, b, c, pointer + 2), program, output)
    }
    Some(#("3", operand)) -> {
      case a {
        0 -> run_program(Computer(a, b, c, pointer + 2), program, output)
        _ -> run_program(Computer(a, b, c, literal(operand)), program, output)
      }
    }
    Some(#("4", _)) -> {
      let b = int.bitwise_exclusive_or(b, c)
      run_program(Computer(a, b, c, pointer + 2), program, output)
    }
    Some(#("5", operand)) -> {
      let output = list.append(output, [combo(computer, operand) % 8])
      // run_program(Computer(a, b, c, pointer + 2), program, output)
      case list.take(program, list.length(output)) == list.map(output, int.to_string) {
        True -> run_program(Computer(a, b, c, pointer + 2), program, output)
        False -> output
      }
    }
    Some(#(opcode, operand)) -> {
      let assert Ok(denominator) = int.power(2, int.to_float(combo(computer, operand)))
      let r = a / float.round(denominator)
      case opcode {
        "0" -> run_program(Computer(r, b, c, pointer + 2), program, output)
        "6" -> run_program(Computer(a, r, c, pointer + 2), program, output)
        "7" -> run_program(Computer(a, b, r, pointer + 2), program, output)
        _ -> output
      }
    }
    _ -> output
  }
}

fn part1(input: String) -> String {
  let #(computer, program) = parse_input(input)
  computer
  |> run_program(program, [])
  |> list.reverse()
  |> list.map(int.to_string)
  |> string.join(",")
}

fn try_register_a(computer: Computer, program: Program) -> Int {
  let output = 
    computer
    |> run_program(program, [])
    |> list.map(int.to_string)

  case output {
    in if output == program -> computer.a
    _ -> {
      let computer = Computer(..computer, a: computer.a + 1) 
      try_register_a(computer, program)
    }
  }
}

fn part2(input: String) -> Int {
  let #(computer, program) = parse_input(input)
  try_register_a(computer, program)
}

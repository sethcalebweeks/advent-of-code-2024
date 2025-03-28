import gleam/int
import gleam/float
import gleam/io
import gleam/string
import gleam/result
import gleam/list
import gleam/regexp.{Match}
import gleam/option.{Some, None}
import gleam/dict.{type Dict}
import simplifile as file

const example = "
x00: 1
x01: 0
x02: 1
x03: 1
x04: 0
y00: 1
y01: 1
y02: 1
y03: 1
y04: 1

ntg XOR fgs -> mjb
y02 OR x01 -> tnw
kwq OR kpj -> z05
x00 OR x03 -> fst
tgd XOR rvg -> z01
vdt OR tnw -> bfw
bfw AND frj -> z10
ffh OR nrd -> bqk
y00 AND y03 -> djm
y03 OR y00 -> psh
bqk OR frj -> z08
tnw OR fst -> frj
gnj AND tgd -> z11
bfw XOR mjb -> z00
x03 OR x00 -> vdt
gnj AND wpb -> z02
x04 AND y00 -> kjc
djm OR pbm -> qhw
nrd AND vdt -> hwm
kjc AND fst -> rvg
y04 OR y02 -> fgs
y01 AND x02 -> pbm
ntg OR kjc -> kwq
psh XOR fgs -> tgd
qhw XOR tgd -> z09
pbm OR djm -> kpj
x03 XOR y03 -> ffh
x00 XOR y04 -> ntg
bfw OR bqk -> z06
nrd XOR fgs -> wpb
frj XOR qhw -> z04
bqk OR frj -> z07
y03 OR x01 -> nrd
hwm AND bqk -> z03
tgd XOR rvg -> z12
tnw OR pbm -> gnj
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 2024 = part1(example)
  // let assert "co,de,ka,ta" = part2(example)
  part1(input) |> int.to_string |> io.println
  // part2(input, 100) |> int.to_string |> io.println
}

type Expression {
  AND(a: String, b: String)
  OR(a: String, b: String)
  XOR(a: String, b: String)
  Value(value: Int)
}
type Connections = Dict(String, Expression)

fn parse_input(input: String) -> Connections {
  let assert [initial, gates] = input |> string.trim |> string.split("\n\n")

  let initial =
    initial
    |> string.split("\n")
    |> list.fold(dict.new(), fn(acc, line) {
      let assert [var, val] = string.split(line, ": ")
      let assert Ok(val) = int.parse(val)
      dict.insert(acc, var, Value(val))
    })

  let assert Ok(re) = regexp.from_string("(\\w+) (XOR|OR|AND) (\\w+) -> (\\w+)")

  regexp.scan(re, gates)
  |> list.fold(initial, fn(acc, match) {
    let assert Match(_, [Some(a), Some(op), Some(b), Some(var)]) = match
    case op {
      "XOR" -> dict.insert(acc, var, XOR(a, b))
      "OR" -> dict.insert(acc, var, OR(a, b))
      "AND" -> dict.insert(acc, var, AND(a, b))
      _ -> acc
    }
  })
}

fn eval(expr: Expression, connections: Connections) -> Int {
  case expr {
    AND(a, b) -> {
      let assert Ok(a) = dict.get(connections, a)
      let assert Ok(b) = dict.get(connections, b)
      int.bitwise_and(eval(a, connections), eval(b, connections))
    }
    OR(a, b) -> {
      let assert Ok(a) = dict.get(connections, a)
      let assert Ok(b) = dict.get(connections, b)
      int.bitwise_or(eval(a, connections), eval(b, connections))
    }
    XOR(a, b) -> {
      let assert Ok(a) = dict.get(connections, a)
      let assert Ok(b) = dict.get(connections, b)
      int.bitwise_exclusive_or(eval(a, connections), eval(b, connections))
    }
    Value(value) -> value
  }
}

fn part1(input: String) -> Int {
  let connections = parse_input(input)
  connections
  |> dict.keys()
  |> list.filter(fn(var) { string.starts_with(var, "z") })
  |> list.sort(string.compare)
  |> list.fold(0, fn(sum, var) {
    let val = 
      connections
      |> dict.get(var)
      |> result.unwrap(Value(0))
      |> eval(connections)
    let position = var |> string.drop_start(1) |> int.parse |> result.unwrap(0)
    sum + {int.power(2, int.to_float(position)) |> result.unwrap(0.0) |> float.round} * val
  })
}

fn part2(input: String) -> String {
  ""
}
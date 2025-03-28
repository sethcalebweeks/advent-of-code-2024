import gleam/int
import gleam/io
import gleam/list.{Stop, Continue}
import gleam/string
import gleam/result
import gleam/pair
import gleam/option.{Some, None}
import gleam/set.{type Set}
import gleam/dict.{type Dict}
import simplifile as file

const example = "
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  // let assert 7 = part1(example)
  // let assert "co,de,ka,ta" = part2(example)
  // part1(input) |> int.to_string |> io.println
  part2(input) |> io.println
}

type Network = Dict(String, Set(String))

fn add_connection(network: Network, a: String, b: String) -> Network {
  dict.upsert(network,a, fn(opt) {
    case opt {
      Some(set) -> set.insert(set, b)
      None -> set.new() |> set.insert(b)
    }
  })
}

fn parse_input(input: String) -> Network {
  input
  |> string.trim
  |> string.split("\n")
  |> list.fold(dict.new(), fn(network, connection) {
    let assert [a, b] = string.split(connection, "-")
    network
    |> add_connection(a, b)
    |> add_connection(b, a)
  })
}

fn connections(network: Network, computer: String) -> Set(String) {
  case dict.get(network, computer) {
    Ok(set) -> set
    Error(Nil) -> set.new()
  }
}

type Cycles = Set(Set(String))

fn cycles_of(network: Network, size: Int) -> Cycles {
  dict.fold(network, set.new(), fn(cycles, computer, _) {
    cycles_recursive(network, computer, #(computer, size, set.new(), cycles))
  })
}

type Acc = #(String, Int, Set(String), Cycles)

fn cycles_recursive(network: Network, stop: String, acc: Acc) -> Cycles {
  let #(current, size, path, cycles) = acc
  let path = set.insert(path, current)
  let connections = connections(network, current)
  case size == 0, set.contains(connections, stop) {
    True, True -> set.insert(cycles, path)
    True, False -> cycles
    _, _ -> set.fold(connections, cycles, fn(cycles, next) {
      cycles_recursive(network, stop, #(next, size - 1, path, cycles))
    })
  }
}

fn part1(input: String) -> Int {
  input
  |> parse_input()
  |> cycles_of(2)
  |> set.filter(fn(cycle) {
    cycle
    |> set.to_list
    |> list.any(fn(computer) { string.starts_with(computer, "t") })
  })
  |> set.size()
}

fn largest_dense_network(network: Network, size: Int) {
  let networks = dense_network(network, size)
  io.debug(size)
  case networks |> set.from_list() |> set.size() {
    1 -> list.first(networks) |> result.unwrap([])
    _ -> largest_dense_network(network, size + 1)
  }
}

fn dense_network(network: Network, size: Int) {
  let combos = 
    network
    |> dict.keys()
    |> list.combinations(size)

  io.debug(list.length(combos))
  combos
  |> list.filter(fn(combination) {
    let network_size = 
      combination
      |> list.fold(set.from_list(combination), fn(set, computer) {
        network
        |> connections(computer)
        |> set.insert(computer)
        |> set.intersection(set)
      })
      |> set.size
    network_size == size
  })
}

fn part2(input: String) -> String {
  input
  |> parse_input()
  |> largest_dense_network(6)
  |> list.sort(string.compare)
  |> string.join(",")
}

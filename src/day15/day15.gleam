import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/result
import gleam/pair
import gleam/option.{Some, None}
import gleam/dict.{type Dict}
import gleam/regexp.{Match}
import simplifile as file

const example = "
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 10092 = part1(example)
  // let assert 9021 = part2(example)
  part1(input) |> int.to_string |> io.println
  // part2(input) |> int.to_string |> io.println
}

type Map = Dict(#(Int, Int), String)
type Position = #(Int, Int)

fn parse_input(input: String) {
  let assert [map, moves] = string.split(input, "\n\n")
  
  let #(map, robot) = 
    map
    |> string.trim()
    |> string.split("\n")
    |> list.index_fold(#(dict.new(), #(0, 0)), fn(acc, line, x) {
      line
      |> string.to_graphemes()
      |> list.index_fold(acc, fn(acc, char, y) {
        let #(map, robot) = acc
        case char {
          "@" -> #(dict.insert(map, #(x, y), char), #(x, y))
          _ -> #(dict.insert(map, #(x, y), char), robot)
        }
        
      })
    })
  
  let assert Ok(re) = regexp.from_string(">|v|\\^|<")
  let moves = 
    re
    |> regexp.scan(moves)
    |> list.map(fn(match) {
      let assert Match(char, _) = match
      char
    })

  #(map, robot, moves)
}

fn next_position(position: Position, direction: String) -> Position {
  let #(x, y) = position
  case direction {
    ">" -> #(x, y + 1)
    "<" -> #(x, y - 1)
    "^" -> #(x - 1, y)
    "v" -> #(x + 1, y)
    _ -> position
  }
}

fn move(map: Map, from: Position, item: String, direction: String) -> Result(Map, Map) {
  let next = next_position(from, direction)
  case dict.get(map, next) {
    Ok(".") -> {
      map
      |> dict.insert(from, ".")
      |> dict.insert(next, item)
      |> Ok
    }
    Ok("O") -> {
      case move(map, next, "O", direction) {
        Ok(map) -> {
          map
          |> dict.insert(from, ".")
          |> dict.insert(next, item)
          |> Ok
        }
        Error(map) -> Error(map)
      } 
    }
    _ -> Error(map)
  }
}

fn map_to_string(map: Map, width: Int, height: Int) {
  list.range(0, height - 1)
  |> list.fold("", fn(lines, x) {
    list.range(0, width - 1)
    |> list.fold(lines, fn(line, y) {
      let assert Ok(char) = dict.get(map, #(x, y))
      string.append(line, char)
    })
    |> string.append("\n")
  })
}

fn gps_sum(map: Map) -> Int {
  dict.fold(map, 0, fn(acc, position, char) {
    let #(x, y) = position
    case char {
      "O" -> acc + {100 * x + y}
      _ -> acc
    }
  })
}

fn part1(input: String) -> Int {
  let #(map, robot, moves) = parse_input(input)
  moves
  |> list.fold(#(map, robot), fn(acc, direction) {
    let #(map, from) = acc
    let to = next_position(from, direction)
    case move(map, from, "@", direction) {
      Ok(map) -> #(map, to)
      Error(map) -> #(map, from)
    }
  })
  |> pair.first()
  |> gps_sum()
}

fn part2(input: String) -> Int {
  0
}

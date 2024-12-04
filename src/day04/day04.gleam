import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/dict.{type Dict, get, insert}
import simplifile as file

const example = "
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 18 = part1(example)
  let assert 9 = part2(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

fn parse_word_search(input: String) -> Dict(#(Int, Int), String) {
  input
  |> string.trim()
  |> string.split("\n")
  |> list.index_fold(dict.new(), fn(dict, line, x) {
    string.to_graphemes(line)
    |> list.index_fold(dict, fn(dict, char, y) {
      insert(dict, #(x, y), char)
    })
  })
}

fn xmas_search(position, ws) {
  let #(x, y) = position
  let search_space = [
    #(#(x, y - 1), #(x, y - 2), #(x, y - 3)),
    #(#(x - 1, y), #(x - 2, y), #(x - 3, y)),
    #(#(x, y + 1), #(x, y + 2), #(x, y + 3)),
    #(#(x + 1, y), #(x + 2, y), #(x + 3, y)),
    #(#(x - 1, y - 1), #(x - 2, y - 2), #(x - 3, y - 3)),
    #(#(x + 1, y - 1), #(x + 2, y - 2), #(x + 3, y - 3)),
    #(#(x - 1, y + 1), #(x - 2, y + 2), #(x - 3, y + 3)),
    #(#(x + 1, y + 1), #(x + 2, y + 2), #(x + 3, y + 3))
  ]
  search_space
  |> list.fold(0, fn(count, direction) {
    let #(m, a, s) = direction
    case get(ws, m), get(ws, a), get(ws, s) {
      Ok("M"), Ok("A"), Ok("S") -> count + 1
      _, _, _ -> count
    }
  })
}

fn part1(input: String) -> Int {
  let word_search = parse_word_search(input)
  dict.fold(word_search, 0, fn(count, position, char) {
    case char {
      "X" -> count + xmas_search(position, word_search)
      _ -> count
    }
  })
}

fn x_mas_search(position, ws) {
  let #(x, y) = position
  let c1 = #(x - 1, y - 1)
  let c2 = #(x - 1, y + 1)
  let c3 = #(x + 1, y + 1)
  let c4 = #(x + 1, y - 1)
  case get(ws, c1), get(ws, c2), get(ws, c3), get(ws, c4) {
    Ok("M"), Ok("M"), Ok("S"), Ok("S") -> 1
    Ok("S"), Ok("M"), Ok("M"), Ok("S") -> 1
    Ok("S"), Ok("S"), Ok("M"), Ok("M") -> 1
    Ok("M"), Ok("S"), Ok("S"), Ok("M") -> 1
    _, _, _, _ -> 0
  }
}

fn part2(input: String) -> Int {
  let word_search = parse_word_search(input)
  dict.fold(word_search, 0, fn(count, position, char) {
    case char {
      "A" -> count + x_mas_search(position, word_search)
      _ -> count
    }
  })
}

// import gleam/int
// import gleam/io
// import gleam/list
// import gleam/string
// import gleam/result
// import gleam/option.{Some, None}
// import gleam/set.{type Set}
// import gleam/dict.{type Dict}
// import simplifile as file

// const example = "
// #################
// #...#...#...#..E#
// #.#.#.#.#.#.#.#.#
// #.#.#.#...#...#.#
// #.#.#.#.###.#.#.#
// #...#.#.#.....#.#
// #.#.#.#.#.#####.#
// #.#...#.#.#.....#
// #.#.#####.#.###.#
// #.#.#.......#...#
// #.#.###.#####.###
// #.#.#...#.....#.#
// #.#.#.#####.###.#
// #.#.#.........#.#
// #.#.#.#########.#
// #S#.............#
// #################
// "

// pub fn main() {
//   let assert Ok(input) = file.read("input")
//   // let assert 11048 = part1(example)
//   let assert 64 = part2(example, 11048)
//   // part1(input) |> int.to_string |> io.println
//   part2(input, 89460) |> int.to_string |> io.println
// }

// type Tile = #(Int, Int)
// type Map = Set(Tile)
// type Node {
//   North(tile: Tile)
//   South(tile: Tile)
//   East(tile: Tile)
//   West(tile: Tile)
// }

// fn parse_input(input: String) -> #(Map, Node, Tile) {
//   input
//   |> string.trim
//   |> string.split("\n")
//   |> list.index_fold(#(set.new(), East(#(0, 0)), #(0, 0)), fn(acc, line, y) {
//     line
//     |> string.to_graphemes
//     |> list.index_fold(acc, fn(acc, char, x) {
//       let #(map, start, end) = acc
//       case char {
//         "." -> #(set.insert(map, #(x, y)), start, end)
//         "E" -> #(set.insert(map, #(x, y)), start, #(x, y))
//         "S" -> #(set.insert(map, #(x, y)), East(#(x, y)), end)
//         _ -> acc
//       }
//     })
//   })
// }

// fn neighbors(node: Node, map: Map, visited: Set(Node)) -> List(#(Node, Int)) {
//   case node {
//     North(tile) -> [
//       #(North(tile: #(tile.0, tile.1 - 1)), 1),
//       #(East(tile), 1000),
//       #(West(tile), 1000)
//     ]
//     South(tile) -> [
//       #(South(tile: #(tile.0, tile.1 + 1)), 1),
//       #(East(tile), 1000),
//       #(West(tile), 1000)
//     ]
//     East(tile) -> [
//       #(East(tile: #(tile.0 + 1, tile.1)), 1),
//       #(North(tile), 1000),
//       #(South(tile), 1000)
//     ]
//     West(tile) -> [
//       #(West(tile: #(tile.0 - 1, tile.1)), 1),
//       #(North(tile), 1000),
//       #(South(tile), 1000)
//     ]
//   }
//   |> list.filter(fn(next) { 
//     let #(node, _) = next
//     set.contains(map, node.tile) && !set.contains(visited, node)
//   })
// }

// fn lowest_score(scores: Dict(Node, Int), visited: Set(Node)) -> Node {
//   let assert Ok(lowest) = 
//     scores
//     |> dict.to_list
//     |> list.filter(fn(pair) { !set.contains(visited, pair.0) })
//     |> list.sort(fn(a, b) { 
//       int.compare(a.1, b.1)
//     })
//     |> list.first
//   lowest.0
// }

// fn dijsktra(map: Map, node: Node, end: Tile, scores: Dict(Node, Int), visited: Set(Node)) {
//   case node.tile == end {
//     True -> dict.get(scores, node) |> result.unwrap(0)
//     False -> {
//       let visited = set.insert(visited, node)
//       let scores = 
//         node
//         |> neighbors(map, visited)
//         |> list.fold(scores, fn(scores, next) {
//           let #(next, score) = next
//           let assert Ok(node_score) = dict.get(scores, node)
//           dict.upsert(scores, next, fn(opt) {
//             case opt {
//               None -> node_score + score
//               Some(current) -> int.min(current, node_score + score)
//             }
//           })
//         })
//       let next = lowest_score(scores, visited)
//       dijsktra(map, next, end, scores, visited)
//     }
//   }
// }

// fn part1(input: String) -> Int {
//   let #(map, start, end) = parse_input(input)
//   let scores = dict.new() |> dict.insert(start, 0)
//   dijsktra(map, start, end, scores, set.new())
// }

// // fn lowest_in_queue(queue: Set(Node), scores: Dict(Node, Int)) -> Result(#(Node, Set(Node)), Nil) {
// //   let sorted = 
// //     queue
// //     |> set.to_list
// //     |> list.sort(fn(a, b) { 
// //       let assert Ok(a) = dict.get(scores, a)
// //       let assert Ok(b) = dict.get(scores, b)
// //       int.compare(a, b)
// //     })
// //   use node <- result.try(list.first(sorted))
// //   #(node, set.delete(queue, node))
// // }

// fn best_paths(map: Map, node: Node, end: Tile, visited: Set(Node), max: Int) {
//   case lowest_in_queue(queue, scores) == node {
//     Error(nil) -> dict.get(scores, node) |> result.unwrap(0)
//     Ok(#(node, queue)) -> {
//       let visited = set.insert(visited, node)
//       let scores = 
//         node
//         |> neighbors(map, visited)
//         |> list.fold(scores, fn(scores, next) {
//           let #(next, score) = next
//           let assert Ok(node_score) = dict.get(scores, node)
//           dict.upsert(scores, next, fn(opt) {
//             case opt {
//               None -> node_score + score
//               Some(current) -> int.min(current, node_score + score)
//             }
//           })
//         })
//       let next = lowest_score(scores, visited)
//       best_paths(map, next, end, scores, queue, visited)
//     }
//   }
// }

// fn print_map(visited: Set(Tile), map: Map, width: Int, height: Int) {
//   list.range(0, height - 1)
//   |> list.each(fn(y) {
//     list.range(0, width - 1)
//     |> list.fold("", fn(tiles, x) {
//       case set.contains(visited, #(x, y)) {
//         True -> tiles <> "O"
//         False -> case set.contains(map, #(x, y)) {
//           True -> tiles <> "."
//           False -> tiles <> "#"
//         }
//       }
//     })
//     |> io.println()
//   })
//   visited
// }

// fn part2(input: String, max: Int) -> Int {
//   let #(map, start, end) = parse_input(input)
//   best_paths(map, start, end, 0, set.new(), max)
//   |> set.from_list()
//   |> set.map(fn(node) { node.tile })
//   |> set.size()
//   |> int.add(1)
// }

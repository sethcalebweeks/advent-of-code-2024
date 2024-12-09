import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/order.{Gt, Eq, Lt}
import simplifile as file

const example = "
2333133121414131402
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  let assert 1928 = part1(example)
  let assert 2858 = part2(example)
  part1(input) |> int.to_string |> io.println
  part2(input) |> int.to_string |> io.println
}

type Block {
  Free(size: Int)
  File(size: Int, id: Int)
}
type Disk = List(Block)

fn parse_input(input: String) -> #(Disk, Int) {
  let #(disk, _, total_free) = 
    input
    |> string.trim
    |> string.to_graphemes
    |> list.index_fold(#([], 0, 0), fn(acc, char, i) {
      let #(blocks, id, total_free) = acc
      let assert Ok(size) = int.parse(char)
      case i % 2 {
        0 -> #([File(size, id), ..blocks], id + 1, total_free)
        _ if size > 0 -> #([Free(size), ..blocks], id, total_free + size)
        _ -> acc
      }
    })
  #(disk, total_free)
}

fn move_file(file: Block, front: Disk) -> Disk {
  let assert File(size, id) = file
  let assert #(files, [Free(available), ..rest]) = list.split_while(front, is_file)
  case int.compare(size, available) {
    Gt -> list.flatten([files, [File(available, id)], rest, [File(size - available, id), Free(available)]])
    Eq -> list.flatten([files, [file], rest, [Free(size)]])
    Lt -> list.flatten([files, [file, Free(available - size)], rest, [Free(size)]])
  }
}

fn is_file(block: Block) -> Bool {
  case block {
    File(_, _) -> True
    Free(_) -> False
  }
}

fn is_free(block: Block) -> Bool { !is_file(block) }

fn merge_free(disk: Disk) -> Disk {
  case disk {
    [Free(s1), Free(s2), ..rest] -> merge_free([Free(s1 + s2), ..rest])
    _ -> disk
  }
}

fn disk_to_string(disk: Disk) -> String {
  list.fold(disk, "", fn(acc, block) {
    case block {
      Free(size) -> acc <> string.repeat(".", size)
      File(size, id) -> acc <> string.repeat(int.to_string(id), size)
    }
  })
}

fn defragment(disk: Disk, total_free: Int) -> Disk {
  case disk {
    [Free(size), ..] if size == total_free -> disk // done
    [File(_, _) as file, ..front] -> 
      file
      |> move_file(list.reverse(front))
      |> list.reverse
      |> merge_free
      |> defragment(total_free)
    [Free(_) as free, File(_, _) as file, ..front] ->
      file
      |> move_file(list.reverse(front))
      |> list.reverse
      |> list.prepend(free)
      |> merge_free
      |> defragment(total_free)
    _ -> disk
  }
}

fn checksum(disk: Disk) -> Int {
  disk
  |> list.reverse
  |> list.flat_map(fn(block) {
    case block {
      File(size, id) -> list.repeat(id, size)
      Free(size) -> list.repeat(0, size)
    }
  })
  |> list.index_fold(0, fn(sum, id, i) { sum + id * i })
}

fn part1(input: String) -> Int {
  let #(disk, total_free) = parse_input(input)
  disk
  |> defragment(total_free)
  |> checksum()
}

fn move_whole_file(file: Block, front: Disk) -> Disk {
  let assert File(size, id) = file
  let free_space = 
    list.split_while(front, fn(block) {
      case block {
        Free(available) if available >= size -> False
        _ -> True
      }
    })
  case free_space {
    #(files, [Free(available), ..rest]) ->
      list.flatten([files, [File(size, id), Free(available - size)], rest, [Free(size)]])
    _ -> list.append(front, [file])
  }
}

fn part2(input: String) -> Int {
  let #(original_disk, _) = parse_input(input)
  original_disk
  |> list.filter(is_file)
  |> list.fold(original_disk, fn(disk, file) {
    let assert #(back, [_, ..front]) = list.split_while(disk, fn(f) { f != file })
    list.flatten([back, list.reverse(move_whole_file(file, list.reverse(front)))])
  })
  |> checksum()
}

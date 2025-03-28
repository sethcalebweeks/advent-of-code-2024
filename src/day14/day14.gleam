import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/erlang/process
import gleam/set.{type Set}
import gleam/option.{Some}
import gleam/regexp.{Match}
import simplifile as file

const example = "
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
"

pub fn main() {
  let assert Ok(input) = file.read("input")
  // let assert 12 = part1(example, 11, 7)
  // part1(input, 101, 103) |> int.to_string |> io.println
  part2(input, 101, 103)
}

type Velocity = #(Int, Int)
type Position = #(Int, Int)
type Robot {
  Robot(position: Position, velocity: Velocity)
}

fn assert_parse_int(input: String) -> Int {
  let assert Ok(x) = int.parse(input)
  x
}

fn parse_input(input: String) -> List(Robot) {
  let assert Ok(re) = regexp.from_string("p=(\\d+),(\\d+) v=(-*\\d+),(-*\\d+)")
  regexp.scan(re, input)
  |> list.map(fn(match) {
    let assert Match(_, [Some(x), Some(y), Some(vx), Some(vy)]) = match
    Robot(
      #(assert_parse_int(x), assert_parse_int(y)),
      #(assert_parse_int(vx), assert_parse_int(vy))
    )
  })
}

fn position_after(robot: Robot, seconds: Int, width: Int, height: Int) -> Position {
  let Robot(#(x, y), #(vx, vy)) = robot
  let assert Ok(new_x) = int.modulo(x + vx * seconds, width)
  let assert Ok(new_y) = int.modulo(y + vy * seconds, height)
  #(new_x, new_y)
}

fn in_quadrants(positions: List(Position), width: Int, height: Int) -> Int {
  positions
  |> list.fold(#(0, 0, 0, 0), fn(quadrants, position) {
    let #(tl, tr, bl, br) = quadrants
    let #(x, y) = position
    case position {
      #(x, y) if x < width / 2 && y < height / 2 -> #(tl + 1, tr, bl, br)
      #(x, y) if x > width / 2 && y < height / 2 -> #(tl, tr + 1, bl, br)
      #(x, y) if x < width / 2 && y > height / 2 -> #(tl, tr, bl + 1, br)
      #(x, y) if x > width / 2 && y > height / 2 -> #(tl, tr, bl, br + 1)
      _ -> quadrants
    }
  })
  |> fn(quadrants) {
    let #(tl, tr, bl, br) = quadrants
    tl * tr * bl * br
  }
}

fn part1(input: String, width: Int, height: Int) -> Int {
  input
  |> parse_input()
  |> list.map(fn(robot) { position_after(robot, 100, width, height) })
  |> in_quadrants(width, height)
}

fn print_positions(positions: List(Position), width: Int, height: Int) {
  let positions = set.from_list(positions)
  list.range(0, height)
  |> list.fold("", fn(lines, x) {
    list.range(0, width)
    |> list.fold(lines, fn(tiles, y) {
      case set.contains(positions, #(x, y)) {
        True -> tiles <> "#"
        False -> tiles <> " "
      }
    })
    |> string.append("\n")
  })
}

fn loop(robots: List(Robot), seconds: Int, width: Int, height: Int, pics: Set(String)) {
  io.println(int.to_string(seconds))
  let pic = 
    robots
    |> list.map(fn(robot) { position_after(robot, seconds, width, height) })
    |> print_positions(width, height)
  case set.contains(pics, pic) {
    True -> io.println("PICTURE DUPLICATE")
    False -> Nil
  } 
  file.write("output", pic)
  process.sleep(1000)
  loop(robots, seconds + 1, width, height, set.insert(pics, pic))
}

fn part2(input: String, width: Int, height: Int) -> Int {
  loop(parse_input(input), 6667, width, height, set.new())
  // Duplicate at 10403
  // 5201 too low
  // Searched to 6620
  // Searched above 10000

}


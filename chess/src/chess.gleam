import board
import gleam/io
import gleam/option
import square

pub fn main() {
  let assert option.Some(bb) =
    board.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

  let assert option.Some(sq) = square.from_string("e4")
  io.println(square.to_string(sq, False))

  bb |> board.pretty_print() |> io.println()
}

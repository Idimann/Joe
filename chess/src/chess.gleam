import board
import bit_board
import gleam/io
import gleam/option
import move

pub fn main() {
  let assert option.Some(b) =
    board.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

  let bb =
    b
    |> move.make_apply([
      #("e2", "e4", move.Normal),
      #("e7", "e5", move.Normal),
      #("g1", "f3", move.Normal),
      #("b8", "c6", move.Normal),
      #("f1", "b5", move.Normal),
      #("a7", "a6", move.Normal),
      #("b5", "c6", move.Normal),
      #("b7", "c6", move.Normal),
      #("e1", "g1", move.Castle),
    ])

  bb |> board.pretty_print() |> io.println()
  bb.pawns |> bit_board.pretty_print() |> io.println()
}

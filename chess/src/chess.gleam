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
      move.normal("e2", "e4"),
      move.normal("d7", "d5"),
      move.normal("e4", "e5"),
      move.normal("f7", "f5"),
      move.en_passant("e5"),
      move.normal("a7", "a6"),
      move.normal("f6", "f7"),
      move.normal("a6", "a5"),
      move.promotion("f7", "g8", move.Queen),
    ])

  bb |> board.pretty_print() |> io.println()
  bb.pawns |> bit_board.pretty_print() |> io.println()
}

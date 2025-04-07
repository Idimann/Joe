import board
import gleam/dict
import gleam/io
import gleam/option
import gleam/list
import move
import square
import tablegen

// Tables should stay. Instead of using bit_boards, they just use squares/moves directly.
pub fn main() {
  let assert option.Some(b) =
    board.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

  let tables = tablegen.gen_tables()

  let assert Ok(sqs) =
    dict.get(tables.pawn_attacks, {
      let assert option.Some(x) = square.from_string("a7")
      x
    })

  list.each(sqs, fn(x) {
    square.to_string(x, False)
    |> io.println()
  })

  let bb =
    move.apply_list(b, [
      move.normal("e2", "e4"),
      move.normal("e7", "e5"),
      move.normal("g1", "f3"),
      move.normal("b8", "c6"),
      move.normal("f1", "b5"),
      move.normal("a7", "a6"),
      move.normal("b5", "a4"),
      move.normal("g8", "f6"),
      move.castle(move.Kingside),
      move.normal("f8", "e7"),
      move.normal("f1", "e1"),
      move.normal("b7", "b5"),
      move.normal("a4", "b3"),
      move.normal("d7", "d6"),
      move.normal("c2", "c3"),
      move.castle(move.Kingside),
      move.normal("h2", "h3"),
      move.normal("c6", "b8"),
      move.normal("d2", "d4"),
      move.normal("b8", "d7"),
      move.normal("c3", "c4"),
      move.normal("c7", "c6"),
      move.normal("c4", "b5"),
      move.normal("a6", "b5"),
      move.normal("b1", "c3"),
      move.normal("c8", "b7"),
      move.normal("c1", "g5"),
      move.normal("b5", "b4"),
    ])

  bb |> board.pretty() |> io.println()
}

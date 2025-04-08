import board
import gleam/io
import gleam/list
import gleam/option
import move
import movegen
import tablegen

// Slide tables as they are right now are dumb.
// You should use tables of rows, lines and diagonals instead
// We don't need these move tables. They are only efficient if you can use and and or
// operations.
pub fn main() {
  let tables = tablegen.gen_tables()

  let assert option.Some(b) =
    board.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

  movegen.gen_simple(b, tables)
  |> list.each(fn(x) { move.to_string(x, False) |> io.println() })

  b |> board.pretty() |> io.println()
}

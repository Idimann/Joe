import board
import gleam/io
import gleam/option
import movegen
import tablegen
import positions

pub fn main() {
  let tables = tablegen.gen_tables()
  let assert option.Some(b) =
    board.from_fen(positions.sicillian)

  movegen.perft_print(b, tables, 4)

  b |> board.pretty() |> io.println()
}

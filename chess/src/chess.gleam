import board
import gleam/dict
import gleam/io
import gleam/option
import bit_line
import tablegen

pub fn main() {
  let assert option.Some(b) =
    board.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
  b |> board.pretty_print() |> io.println()

  let tables = tablegen.gen_tables()

  let assert Ok(v) =
    dict.get(tables.sliding, #(<<0:3, 1:1, 0:4>>, <<0:1, 1:1, 0:4, 1:1, 1:1>>))

  bit_line.pretty(v) |> io.println()
}

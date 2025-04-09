import board
import gleam/io
import gleam/list
import gleam/option
import gleam/dict
import move
import square
import movegen
import tablegen

pub fn main() {
  let tables = tablegen.gen_tables()

  let assert option.Some(b) =
    board.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

  movegen.gen_simple(b, tables)
  |> list.each(fn(x) { move.to_string(x, False) |> io.println() })

  //diag works, o_diag doesn't. Rows and cols haven't been tested at all!!
  let assert option.Some(sq) = square.from_string("e4")
  let assert Ok(sqs) = dict.get(tables.o_diag, sq)
  sqs
  |> list.map(fn(x) { square.to_string(x, False) })
  |> list.each(io.println)

  b |> board.pretty() |> io.println()
}

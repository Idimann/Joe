import board
import gleam/io
import gleam/option

pub fn main() {
  let assert option.Some(bb) =
    board.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -")

  bb |> board.format() |> io.println()
}

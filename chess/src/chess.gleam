import board
import gleam/io
import gleam/option
import square

pub fn main() {
  let assert option.Some(bb) =
    board.from_fen("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")

  let assert option.Some(sq) = square.from_string("e4")
  io.println(square.to_string(sq, False))

  { "Normal:\n" <> bb |> board.pretty_print() } |> io.println()
  {
    "Mirrored:\n"
    <> bb
    |> board.mirror()
    |> board.mirror_h()
    |> board.pretty_print()
  }
  |> io.println()
}

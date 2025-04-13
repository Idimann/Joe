import board
import gleam/option
import positions
import tablegen
import engine

pub fn main() {
  let tables = tablegen.gen_tables()
  let assert option.Some(b) = board.from_fen(positions.mate1)
  // b |> board.pretty() |> io.println()
  engine.simple_game(b, tables, False)
  // search.mcts_do(b, tables, 50).0 |> move.to_string(False) |> io.println()
}

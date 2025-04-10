import board
import gleam/erlang
import gleam/float
import gleam/io
import gleam/option
import gleam/string
import move
import search
import tablegen

pub fn simple_game(b: board.Board, tables: tablegen.Tables, player: Bool) {
  b |> board.pretty() |> io.println()

  case b.white == player {
    True ->
      case erlang.get_line("Your move: ") {
        Ok(ln) ->
          case string.replace(ln, "\n", "") |> string.split(" ") {
            [f] ->
              case f {
                "o" ->
                  simple_game(
                    move.apply(b, move.Castle(move.Kingside))
                      |> board.mirror_h(),
                    tables,
                    player,
                  )
                "O" ->
                  simple_game(
                    move.apply(b, move.Castle(move.Queenside))
                      |> board.mirror_h(),
                    tables,
                    player,
                  )
                _ ->
                  case move.en_passant(f, b.white, b.mirror) {
                    option.Some(m) ->
                      simple_game(
                        move.apply(b, m) |> board.mirror_h(),
                        tables,
                        player,
                      )
                    option.None -> simple_game(b, tables, player)
                  }
              }
            [f, t] ->
              case move.normal(f, t, b.white, b.mirror) {
                option.Some(m) ->
                  simple_game(
                    move.apply(b, m) |> board.mirror_h(),
                    tables,
                    player,
                  )
                option.None -> simple_game(b, tables, player)
              }
            _ -> simple_game(b, tables, player)
          }
        Error(_) -> simple_game(b, tables, player)
      }
    False -> {
      let pl = search.alpha_beta(b, tables, 5)
      io.println("Winning chance: " <> float.to_string(pl.0))

      simple_game(pl.2 |> board.mirror_h(), tables, player)
    }
  }
}

import bit_board
import board
import gleam/list

pub fn simple_eval(b: board.Board, side: Bool) -> Float {
  let assert Ok(val) =
    bit_board.iter_pieces(b.board, fn(_, val) {
      [
        case val {
          bit_board.Empty -> 0.0
          bit_board.Pawn(v) ->
            case v {
              True -> -1.0
              False -> 1.0
            }
          bit_board.Knight(v) ->
            case v {
              True -> -3.0
              False -> 3.0
            }
          bit_board.Bishop(v) ->
            case v {
              True -> -3.5
              False -> 3.5
            }
          bit_board.Queen(v) ->
            case v {
              True -> -9.0
              False -> 9.0
            }
          bit_board.Rook(v) ->
            case v {
              True -> -5.0
              False -> 5.0
            }
          bit_board.King(_) -> 0.0
          bit_board.EnPassant -> 0.0
        },
      ]
    })
    |> list.reduce(fn(acc, x) { acc +. x })

  case b.white == side {
    True -> val
    False -> 0.0 -. val
  }
}

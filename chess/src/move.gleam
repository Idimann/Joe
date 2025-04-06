import bit_board
import board
import gleam/option
import square

pub type PromType {
  Knight
  Bishop
  Rook
  Queen
}

pub type CastleType {
  Kingside
  Queenside
}

pub type Move {
  ///The first is square is 'from', the second one is 'to'
  Normal(square.Square, square.Square)
  Castle(CastleType)
  EnPassant(square.Square)
  Promotion(square.Square, square.Square, PromType)
}

pub fn to_string(m: Move, mir: Bool) -> String {
  case m {
    Normal(f, t) -> square.to_string(f, mir) <> square.to_string(t, mir)
    Castle(t) ->
      case t {
        Kingside -> "o"
        Queenside -> "O"
      }
    EnPassant(f) -> square.to_string(f, mir) <> "+"
    Promotion(f, t, ty) ->
      square.to_string(f, mir)
      <> square.to_string(t, mir)
      <> "="
      <> case ty {
        Knight -> "N"
        Bishop -> "B"
        Rook -> "R"
        Queen -> "Q"
      }
  }
}

pub fn normal(f: String, t: String) -> option.Option(Move) {
  case square.from_string(f), square.from_string(t) {
    option.Some(f), option.Some(t) -> option.Some(Normal(f, t))
    _, _ -> option.None
  }
}

pub fn en_passant(f: String) -> option.Option(Move) {
  case square.from_string(f) {
    option.Some(f) -> option.Some(EnPassant(f))
    _ -> option.None
  }
}

pub fn castle(x: CastleType) -> option.Option(Move) {
  option.Some(Castle(x))
}

pub fn promotion(f: String, t: String, x: PromType) -> option.Option(Move) {
  case square.from_string(f), square.from_string(t) {
    option.Some(f), option.Some(t) -> option.Some(Promotion(f, t, x))
    _, _ -> option.None
  }
}

pub fn apply(b: board.Board, m: Move) -> board.Board {
  board.mirror(case m {
    Normal(f, t) -> {
      let x = bit_board.get(b.board, f)

      board.Board(
        board: b.board
          |> bit_board.move_piece(f, t)
          //Setting en passant
          |> case x {
            bit_board.Pawn(_) if t == f + 16 -> fn(x) {
              bit_board.set(x, f + 8, bit_board.EnPassant)
            }
            _ -> fn(x) { x }
          },
        white: b.white,
        mirror: b.mirror,
        castling: case x {
          bit_board.King(_) -> {
            let assert <<_:2-bits, tk:1-bits, tq:1-bits>> = b.castling
            <<0:2, tk:bits, tq:bits>>
          }
          bit_board.Rook(_) -> {
            //Magic
            let kingside = { f == 0 } == { b.white != b.mirror }

            let assert <<ok:1-bits, oq:1-bits, tk:1-bits, tq:1-bits>> =
              b.castling
            <<
              case kingside {
                True -> <<0:1>>
                False -> ok
              }:bits,
              case kingside {
                True -> oq
                False -> <<0:1>>
              }:bits,
              tk:bits,
              tq:bits,
            >>
          }
          _ -> b.castling
        },
      )
    }
    Castle(ty) ->
      board.Board(
        board: b.board
          //Moving the rook
          |> bit_board.move_piece(
            case ty, b.white != b.mirror {
              Kingside, True | Queenside, False -> 7
              Kingside, False | Queenside, True -> 0
            },
            case ty, b.white != b.mirror {
              Kingside, True | Queenside, False -> 5
              Kingside, False | Queenside, True -> 3
            },
          )
          //Moving the king
          |> bit_board.move_piece(
            case b.white != b.mirror {
              True -> 4
              False -> 3
            },
            case ty, b.white != b.mirror {
              Kingside, True | Queenside, False -> 6
              Kingside, False | Queenside, True -> 2
            },
          ),
        white: b.white,
        mirror: b.mirror,
        castling: <<0:4>>,
      )
    EnPassant(f) ->
      board.Board(
        board: b.board
          //We can do this cause we can be sure that f is not at the end of the board
          |> case bit_board.get(b.board, f + 7) {
            bit_board.EnPassant -> fn(x) { bit_board.move_piece(x, f, f + 7) }
            _ ->
              case bit_board.get(b.board, f + 9) {
                bit_board.EnPassant -> fn(x) {
                  bit_board.move_piece(x, f, f + 9)
                }
                _ -> fn(x) { x }
              }
          },
        white: b.white,
        mirror: b.mirror,
        castling: b.castling,
      )
    Promotion(f, t, ty) ->
      board.Board(
        board: b.board
          |> bit_board.set(f, bit_board.Empty)
          |> bit_board.set(t, case ty {
            Knight -> bit_board.Knight(False)
            Bishop -> bit_board.Bishop(False)
            Rook -> bit_board.Rook(False)
            Queen -> bit_board.Queen(False)
          }),
        white: b.white,
        mirror: b.mirror,
        castling: b.castling,
      )
  })
}

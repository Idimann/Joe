import bit_board
import gleam/int
import gleam/option
import gleam/string
import square

pub type Castling =
  BitArray

pub type Board {
  Board(board: bit_board.Board, white: Bool, mirror: Bool, castling: Castling)
}

//New is always set from the white perspective
pub fn new() {
  Board(board: bit_board.new(), white: True, mirror: False, castling: <<0:4>>)
}

fn from_fen_main(b: Board, i: List(String), s: square.Square) -> Board {
  case i {
    [] -> b
    [head, ..tail] ->
      from_fen_main(
        Board(
          board: case head {
            "P" -> bit_board.set(b.board, s, bit_board.Pawn(False))
            "p" -> bit_board.set(b.board, s, bit_board.Pawn(True))
            "N" -> bit_board.set(b.board, s, bit_board.Knight(False))
            "n" -> bit_board.set(b.board, s, bit_board.Knight(True))
            "B" -> bit_board.set(b.board, s, bit_board.Bishop(False))
            "b" -> bit_board.set(b.board, s, bit_board.Bishop(True))
            "R" -> bit_board.set(b.board, s, bit_board.Rook(False))
            "r" -> bit_board.set(b.board, s, bit_board.Rook(True))
            "Q" -> bit_board.set(b.board, s, bit_board.Queen(False))
            "q" -> bit_board.set(b.board, s, bit_board.Queen(True))
            "K" -> bit_board.set(b.board, s, bit_board.King(False))
            "k" -> bit_board.set(b.board, s, bit_board.King(True))
            _ -> b.board
          },
          white: b.white,
          mirror: b.mirror,
          castling: b.castling,
        ),
        tail,
        case head {
          "/" ->
            case s % 8 {
              0 -> s
              _ -> s - { s % 8 } - 8
            }
          x ->
            case int.parse(x) {
              Ok(n) -> s + n - 1
              Error(_) ->
                case s % 8 {
                  7 -> s - 15
                  _ -> s + 1
                }
            }
        },
      )
  }
}

fn from_fen_side(b: Board, i: String) -> Board {
  let w = case i {
    "w" -> True
    _ -> False
  }

  let func = fn(x) {
    case w {
      True -> x
      False -> bit_board.mirror(x) |> bit_board.mirror_h()
    }
  }

  Board(board: func(b.board), white: w, mirror: !w, castling: case w {
    True -> b.castling
    False -> {
      let assert <<ok:1-bits, oq:1-bits, tk:1-bits, tq:1-bits>> = b.castling

      <<tk:bits, tq:bits, ok:bits, oq:bits>>
    }
  })
}

fn from_fen_castle(b: Board, i: List(String)) -> Board {
  case i {
    [] -> b
    [head, ..tail] ->
      from_fen_castle(
        Board(board: b.board, white: b.white, mirror: b.mirror, castling: {
          let assert <<ok:1-bits, oq:1-bits, tk:1-bits, tq:1-bits>> = b.castling

          case head {
            "K" -> <<1:1, oq:bits, tk:bits, tq:bits>>
            "Q" -> <<ok:bits, 1:1, tk:bits, tq:bits>>
            "k" -> <<ok:bits, oq:bits, 1:1, tq:bits>>
            "q" -> <<ok:bits, oq:bits, tk:bits, 1:1>>
            _ -> <<ok:bits, oq:bits, tk:bits, tq:bits>>
          }
        }),
        tail,
      )
  }
}

fn from_fen_en_passant(b: Board, i: String) -> Board {
  case square.from_string(i) {
    option.Some(x) ->
      Board(
        board: bit_board.set(b.board, x, bit_board.EnPassant),
        white: b.white,
        mirror: b.mirror,
        castling: b.castling,
      )
    option.None -> b
  }
}

pub fn from_fen(fen: String) -> option.Option(Board) {
  case string.split(fen, " ") {
    [main, who, castling, en_passant, ..] ->
      option.Some(
        new()
        |> from_fen_main(string.split(main, ""), 56)
        |> from_fen_castle(string.split(castling, ""))
        |> from_fen_en_passant(en_passant)
        |> from_fen_side(who),
      )
    _ -> option.None
  }
}

fn r_pretty(b: Board, s: square.Square) -> String {
  bit_board.get(b.board, s) |> bit_board.value_to_string(b.white)
  <> " "
  <> case s % 8 == 7 {
    True -> "\n"
    False -> ""
  }
  <> case s == 7 {
    True -> ""
    False ->
      r_pretty(b, case s % 8 {
        7 -> s - 15
        _ -> s + 1
      })
  }
}

pub fn pretty(b: Board) -> String {
  r_pretty(b, 56)
}

pub fn mirror(b: Board) -> Board {
  Board(
    board: bit_board.mirror(b.board),
    white: !b.white,
    mirror: b.mirror,
    castling: {
      let assert <<ok:1-bits, oq:1-bits, tk:1-bits, tq:1-bits>> = b.castling
      <<tk:bits, tq:bits, ok:bits, oq:bits>>
    },
  )
}

pub fn mirror_h(b: Board) -> Board {
  Board(
    board: bit_board.mirror_h(b.board),
    white: b.white,
    mirror: !b.mirror,
    castling: b.castling,
  )
}

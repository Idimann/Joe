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

pub fn make_mir(m: Move, b: board.Board) -> Move {
  let mirror = fn(x) {
    x
    |> case b.white {
      True -> fn(x) { x }
      False -> square.mirror
    }
    |> case b.mirror {
      True -> square.mirror_h
      False -> fn(x) { x }
    }
  }

  case m {
    Normal(f, t) -> Normal(mirror(f), mirror(t))
    Castle(x) -> Castle(x)
    EnPassant(f) -> EnPassant(mirror(f))
    Promotion(f, t, x) -> Promotion(mirror(f), mirror(t), x)
  }
}

pub fn apply(b: board.Board, m: Move) -> board.Board {
  board.mirror(case m {
    Normal(from, to) -> {
      let update = fn(bo) {
        case bit_board.check_bit(bo, from) {
          True ->
            bo |> bit_board.switch_bit(from) |> bit_board.assign_bit(to, 1)
          False -> bit_board.assign_bit(bo, to, 0)
        }
      }

      let u_our = update(b.our)
      let u_their = update(b.their)

      board.Board(
        our: u_our,
        their: u_their,
        pawns: case bit_board.check_bit(b.pawns, from) {
          //This is for en passant
          True ->
            b.pawns
            //This removes previous en passants
            |> bit_board.switch_bit(from)
            |> bit_board.assign_bit(to, 1)
            |> fn(x) { bit_board.and([x, bit_board.or([u_our, u_their])]) }
            |> case to - from {
              16 -> fn(x) { bit_board.switch_bit(x, from + 8) }
              _ -> fn(x) { x }
            }
          False ->
            bit_board.assign_bit(b.pawns, to, 0)
            |> fn(x) { bit_board.and([x, bit_board.or([u_our, u_their])]) }
        },
        knights: update(b.knights),
        diags: update(b.diags),
        lines: update(b.lines),
        white: b.white,
        mirror: b.mirror,
        castling: b.castling,
      )
    }
    Castle(typ) -> {
      let from = 4
      let to = case typ {
        Kingside -> 6
        Queenside -> 2
      }

      let update = fn(x) {
        case typ {
          Kingside -> bit_board.switch_bit(x, 7) |> bit_board.switch_bit(5)
          Queenside -> bit_board.switch_bit(x, 0) |> bit_board.switch_bit(3)
        }
      }

      board.Board(
        our: b.our
          |> update()
          |> bit_board.switch_bit(from)
          |> bit_board.assign_bit(to, 1),
        their: b.their,
        pawns: b.pawns
          //Removing en passant if it's there
          |> fn(x) { bit_board.and([x, bit_board.or([b.our, b.their])]) },
        knights: b.knights,
        diags: b.diags,
        lines: update(b.lines),
        white: b.white,
        mirror: b.mirror,
        castling: {
          let assert <<ok:1-bits, oq:1-bits, t:2-bits>> = b.castling

          case typ {
            Kingside -> <<0:1, oq:bits, t:bits>>
            Queenside -> <<ok:bits, 0:1, t:bits>>
          }
        },
      )
    }
    EnPassant(from) ->
      case
        bit_board.without(b.pawns, [b.our, b.their]) |> bit_board.get_first()
      {
        option.Some(to) ->
          board.Board(
            our: b.our
              |> bit_board.switch_bit(from)
              |> bit_board.assign_bit(to, 1),
            their: bit_board.switch_bit(b.their, to - 8),
            pawns: bit_board.switch_bit(b.pawns, from),
            knights: b.knights,
            diags: b.diags,
            lines: b.lines,
            white: b.white,
            mirror: b.mirror,
            castling: b.castling,
          )
        option.None -> b
      }
    Promotion(from, to, typ) ->
      board.Board(
        our: b.our |> bit_board.switch_bit(from) |> bit_board.assign_bit(to, 1),
        their: bit_board.assign_bit(b.their, to, 0),
        pawns: bit_board.switch_bit(b.pawns, from),
        knights: case typ {
          Knight -> bit_board.switch_bit(b.knights, to)
          _ -> bit_board.assign_bit(b.knights, to, 0)
        },
        diags: case typ {
          Bishop | Queen -> bit_board.switch_bit(b.diags, to)
          _ -> bit_board.assign_bit(b.diags, to, 0)
        },
        lines: case typ {
          Rook | Queen -> bit_board.switch_bit(b.lines, to)
          _ -> bit_board.assign_bit(b.lines, to, 0)
        },
        white: b.white,
        mirror: b.mirror,
        castling: b.castling,
      )
  })
}

pub fn make_apply(b: board.Board, ms: List(option.Option(Move))) -> board.Board {
  case ms {
    [] -> b
    [head, ..tail] ->
      case head {
        option.Some(x) ->
          apply(b, make_mir(x, b)) |> board.mirror_h() |> make_apply(tail)
        option.None -> make_apply(b, tail)
      }
  }
}

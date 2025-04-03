import bit_board
import board
import gleam/option
import square

pub type MoveType {
  Normal
  Castle
  EnPassant
}

///The first is square is 'from', the second one is 'to'
pub type Move =
  #(square.Square, square.Square, MoveType)

pub fn make(f: String, t: String, m: MoveType) -> option.Option(Move) {
  case square.from_string(f), square.from_string(t) {
    option.Some(f), option.Some(t) -> option.Some(#(f, t, m))
    _, _ -> option.None
  }
}

pub fn make_mir(
  f: String,
  t: String,
  m: MoveType,
  b: board.Board,
) -> option.Option(Move) {
  case square.from_string(f), square.from_string(t) {
    option.Some(f), option.Some(t) -> {
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

      option.Some(#(mirror(f), mirror(t), m))
    }
    _, _ -> option.None
  }
}

pub fn apply(b: board.Board, m: Move) -> board.Board {
  let from = m.0
  let to = m.1

  board.mirror(case m.2 {
    Normal -> {
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
            |> bit_board.switch_bit(from)
            |> bit_board.assign_bit(to, 1)
            |> case to - from {
              16 -> fn(x) { bit_board.switch_bit(x, from + 8) }
              _ -> fn(x) { bit_board.and([x, bit_board.or([u_our, u_their])]) }
            }
          False -> bit_board.assign_bit(b.pawns, to, 0)
        },
        knights: update(b.knights),
        diags: update(b.diags),
        lines: update(b.lines),
        white: b.white,
        mirror: b.mirror,
        castling: b.castling,
      )
    }
    Castle -> {
      let update = fn(x) {
        case to {
          //Queenside
          2 -> bit_board.switch_bit(x, 0) |> bit_board.switch_bit(3)
          //Kingside
          _ -> bit_board.switch_bit(x, 7) |> bit_board.switch_bit(5)
        }
      }

      board.Board(
        our: b.our
          |> update()
          |> bit_board.switch_bit(from)
          |> bit_board.assign_bit(to, 1),
        their: b.their,
        pawns: b.pawns,
        knights: b.knights,
        diags: b.diags,
        lines: update(b.lines),
        white: b.white,
        mirror: b.mirror,
        castling: {
          let assert <<ok:1-bits, oq:1-bits, t:2-bits>> = b.castling

          case to {
            //Queenside
            2 -> <<ok:bits, 0:1, t:bits>>
            //Kingside
            _ -> <<0:1, oq:bits, t:bits>>
          }
        },
      )
    }
    EnPassant ->
      board.Board(
        our: b.our |> bit_board.switch_bit(from) |> bit_board.assign_bit(to, 1),
        their: bit_board.switch_bit(b.their, to - 8),
        pawns: bit_board.switch_bit(b.pawns, from),
        knights: b.knights,
        diags: b.diags,
        lines: b.lines,
        white: b.white,
        mirror: b.mirror,
        castling: b.castling,
      )
  })
}

pub fn make_apply(
  b: board.Board,
  ms: List(#(String, String, MoveType)),
) -> board.Board {
  case ms {
    [] -> b
    [head, ..tail] ->
      case make_mir(head.0, head.1, head.2, b) {
        option.Some(m) -> b |> apply(m) |> make_apply(tail)
        option.None -> make_apply(b, tail)
      }
  }
}

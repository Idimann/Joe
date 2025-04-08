import bit_board
import board
import gleam/dict
import gleam/list
import move
import square
import tablegen

fn gen_pawn(
  b: board.Board,
  s: square.Square,
  t: tablegen.Table,
  at: tablegen.Table,
) -> List(move.Move) {
  let assert Ok(main) = dict.get(t, s)
  let assert Ok(attacks) = dict.get(at, s)

  let main_m =
    list.map(main, fn(sq) {
      case bit_board.get(b.board, sq) {
        bit_board.Empty -> {
          let y = { sq - sq % 8 } / 8

          case y {
            7 -> [
              move.Promotion(s, sq, move.Knight),
              move.Promotion(s, sq, move.Bishop),
              move.Promotion(s, sq, move.Rook),
              move.Promotion(s, sq, move.Queen),
            ]
            _ -> [move.Normal(s, sq)]
          }
        }
        _ -> []
      }
    })

  let attack_m =
    list.map(attacks, fn(sq) {
      case bit_board.get(b.board, sq) {
        bit_board.Pawn(True)
        | bit_board.Knight(True)
        | bit_board.Bishop(True)
        | bit_board.Rook(True)
        | bit_board.Queen(True) -> {
          let y = { sq - sq % 8 } / 8

          case y {
            7 -> [
              move.Promotion(s, sq, move.Knight),
              move.Promotion(s, sq, move.Bishop),
              move.Promotion(s, sq, move.Rook),
              move.Promotion(s, sq, move.Queen),
            ]
            _ -> [move.Normal(s, sq)]
          }
        }
        bit_board.EnPassant -> [move.EnPassant(s)]
        _ -> []
      }
    })

  list.append(main_m, attack_m) |> list.flatten()
}

fn gen_knight_king(
  b: board.Board,
  s: square.Square,
  t: tablegen.Table,
) -> List(move.Move) {
  let assert Ok(main) = dict.get(t, s)

  main
  |> list.filter(fn(sq) {
    case bit_board.get(b.board, sq) {
      bit_board.Empty
      | bit_board.EnPassant
      | bit_board.Pawn(True)
      | bit_board.Knight(True)
      | bit_board.Bishop(True)
      | bit_board.Rook(True)
      | bit_board.Queen(True) -> True
      _ -> False
    }
  })
  |> list.map(fn(sq) { move.Normal(s, sq) })
}

fn get_line(
  b: bit_board.Board,
  pos: square.Square,
  s: square.Square,
  left: Bool,
  incr: Int,
) -> #(Bool, BitArray) {
  case { s < pos && left } || { s > pos && !left } {
    True -> {
      let func = fn(x) {
        let next =
          get_line(
            b,
            pos,
            case left {
              True -> s + incr
              False -> s - incr
            },
            left,
            incr,
          )

        let bit = case next.0 {
          True -> 1
          False -> x
        }

        case left {
          True -> <<bit:1, next.1:bits>>
          False -> <<next.1:bits, bit:1>>
        }
      }

      case bit_board.get(b, s) {
        bit_board.Empty | bit_board.EnPassant -> #(False, func(0))
        bit_board.Pawn(True)
        | bit_board.Knight(True)
        | bit_board.Bishop(True)
        | bit_board.Rook(True)
        | bit_board.Queen(True) -> #(False, func(1))
        _ -> #(True, func(0))
      }
    }
    False -> #(False, <<>>)
  }
}

pub fn gen_rook(
  b: board.Board,
  s: square.Square,
  t: tablegen.SlideTable,
) -> List(move.Move) {
  let line_start = s - { s % 8 }

  let line = <<
    get_line(b.board, s, line_start, True, 1).1:bits,
    0:1,
    get_line(b.board, s, line_start + 7, False, 1).1:bits,
  >>

  let assert Ok(ln) = dict.get(t, #(s - line_start, line))

  // ln
  // |> list.filter(fn(sq) {
  //   case bit_board.get(b.board, sq) {
  //     bit_board.Empty
  //     | bit_board.EnPassant
  //     | bit_board.Pawn(True)
  //     | bit_board.Knight(True)
  //     | bit_board.Bishop(True)
  //     | bit_board.Rook(True)
  //     | bit_board.Queen(True) -> True
  //     _ -> False
  //   }
  // })
  // |> list.map(fn(sq) { move.Normal(s, sq) })

  []
}

pub fn gen_simple(b: board.Board, t: tablegen.Tables) -> List(move.Move) {
  bit_board.iter_pieces(b.board, fn(sq, vl) {
    case vl {
      bit_board.Pawn(False) -> gen_pawn(b, sq, t.pawns, t.pawn_attacks)
      bit_board.Knight(False) -> gen_knight_king(b, sq, t.knights)
      bit_board.Rook(False) -> gen_rook(b, sq, t.sliding)
      bit_board.King(False) -> gen_knight_king(b, sq, t.kings)
      _ -> []
    }
  })
}

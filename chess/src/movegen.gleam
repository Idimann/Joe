import bit_board
import board
import gleam/dict
import gleam/list
import move
import square
import tablegen

//Promotions haven't been tested yet
pub fn gen_pawn(
  b: board.Board,
  s: square.Square,
  t: tablegen.Table,
  at: tablegen.Table,
) -> List(move.Move) {
  let assert Ok(got_t) = dict.get(t, s)
  let assert Ok(got_at) = dict.get(at, s)

  list.append(
    bit_board.iterate_collect_list(
      bit_board.or([got_t, bit_board.and([got_at, b.their])]),
      fn(_, so) {
        let y = { so - so % 8 } / 8

        case y {
          7 -> [
            move.Promotion(s, so, move.Knight),
            move.Promotion(s, so, move.Bishop),
            move.Promotion(s, so, move.Rook),
            move.Promotion(s, so, move.Queen),
          ]
          _ -> [move.Normal(s, so)]
        }
      },
    ),
    //En passant
    bit_board.iterate_collect(
      bit_board.and([got_at, bit_board.without(b.pawns, [b.their])]),
      fn(_, _) { move.EnPassant(s) },
    ),
  )
}

pub fn gen_knight(
  b: board.Board,
  s: square.Square,
  t: tablegen.Table,
) -> List(move.Move) {
  let assert Ok(got) = dict.get(t, s)

  bit_board.iterate_collect(bit_board.without(got, [b.our]), fn(_, so) {
    move.Normal(s, so)
  })
}

pub fn gen_lines(
  b: board.Board,
  s: square.Square,
  t: tablegen.SlideTable,
) -> List(move.Move) {
  []
}

pub fn gen_diags(
  b: board.Board,
  s: square.Square,
  t: tablegen.SlideTable,
) -> List(move.Move) {
  []
}

pub fn gen_king(
  b: board.Board,
  s: square.Square,
  t: tablegen.Table,
) -> List(move.Move) {
  let assert Ok(got) = dict.get(t, s)

  bit_board.iterate_collect(bit_board.without(got, [b.our]), fn(_, so) {
    move.Normal(s, so)
  })
}

pub fn gen(b: board.Board, tables: tablegen.Tables) -> List(move.Move) {
  bit_board.iterate_collect_list(b.our, fn(_, so) {
    let check = fn(x) { bit_board.check_bit(x, so) }

    case check(b.pawns) {
      True -> gen_pawn(b, so, tables.pawns, tables.pawn_attacks)
      False ->
        case check(b.knights) {
          True -> gen_knight(b, so, tables.knights)
          False ->
            case check(b.diags) {
              True ->
                list.append(
                  gen_diags(b, so, tables.sliding),
                  case check(b.lines) {
                    True -> gen_lines(b, so, tables.sliding)
                    False -> []
                  },
                )
              False ->
                case check(b.lines) {
                  True -> gen_lines(b, so, tables.sliding)
                  False -> gen_king(b, so, tables.kings)
                }
            }
        }
    }
  })
}

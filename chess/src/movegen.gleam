import bit_board
import board
import gleam/list
import move
import square

//Promotions haven't been tested yet
pub fn gen_pawn(b: board.Board, s: square.Square) -> List(move.Move) {
  todo
}

pub fn gen_knight(b: board.Board, s: square.Square) -> List(move.Move) {
  todo
}

pub fn gen_lines(b: board.Board, s: square.Square) -> List(move.Move) {
  todo
}

pub fn gen_diags(b: board.Board, s: square.Square) -> List(move.Move) {
  todo
}

pub fn gen_king(b: board.Board, s: square.Square) -> List(move.Move) {
  todo
}

pub fn gen(b: board.Board) -> List(move.Move) {
  bit_board.iterate_collect_list(b.our, fn(_, so) {
    let check = fn(x) { bit_board.check_bit(x, so) }

    case check(b.pawns) {
      True -> gen_pawn(b, so)
      False ->
        case check(b.knights) {
          True -> gen_knight(b, so)
          False ->
            case check(b.diags) {
              True ->
                list.append(gen_diags(b, so), case check(b.lines) {
                  True -> gen_lines(b, so)
                  False -> []
                })
              False ->
                case check(b.lines) {
                  True -> gen_lines(b, so)
                  False -> gen_king(b, so)
                }
            }
        }
    }
  })
}

import gleam/option
import bit_board

pub type Square = Int

pub fn is_valid(s: Square) -> Bool {
  s >= 0 && s < 64
}

fn get_first_r(b: bit_board.Board, s: Square) -> option.Option(Square) {
  case is_valid(s) {
    True -> case bit_board.check_bit(b, s) {
      True -> option.Some(s)
      False -> get_first_r(b, s + 1)
    }

    False -> option.None
  }
}

pub fn get_first(b: bit_board.Board) -> option.Option(Square) {
  get_first_r(b, 0)
}

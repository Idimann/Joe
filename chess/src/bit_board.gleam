import gleam/order
import square

pub type Board = BitArray

pub fn is_valid(b: Board) -> Bool {
  case b.bits_size() {
    64 -> True
    _ -> False
  }
}

pub fn check_bit(b: Board, s: square.Square) -> Bool {
  case bit_array.slice(b, s, 1) {
    Ok(bit) -> bit_array.compare(bit, <<1:1>>) == order.Eq
    Error(_) -> False
  }
}

pub fn switch_bit(b: Board, s: square.Square) -> Board {
  case bit_array.slice(b, 0, s) {
    Ok(first) ->
      case bit_array.slice(b, s + 1, bit_array.bit_size(b) - s - 1) {
        Ok(second) -> <<first:bits, 1:1, second:bits>>
        Error(_) -> b
      }
    Error(_) -> b
  }
}

pub fn from_square(s: square.Square) -> Board {
  switch_bit(<<0:64>>, s)
}

import square

pub type Square {
  Empty
  Pawn
  Knight
  Bishop
  Rook
  Queen
  King
  EnPassant
}

pub type Board =
  BitArray

pub fn new() -> Board {
  <<0:size({ 64 * 4 })>>
}

pub fn to_bits(s: Square) -> BitArray {
  case s {
    Empty -> <<0:1, 0:1, 0:1>>
    Pawn -> <<0:1, 0:1, 1:1>>
    Knight -> <<0:1, 1:1, 0:1>>
    Bishop -> <<0:1, 1:1, 1:1>>
    Rook -> <<1:1, 0:1, 0:1>>
    Queen -> <<1:1, 0:1, 1:1>>
    King -> <<1:1, 1:1, 0:1>>
    EnPassant -> <<1:1, 1:1, 1:1>>
  }
}

pub fn set(b: Board, s: square.Square, t: Square) -> Board {
  let bf = s * 4
  let af = { 63 - s } * 4 //63 cause we cut the one we're replacing
  let assert <<p:size(bf)-bits, _:size(4), n:size(af)-bits>> = b

  <<p:bits, to_bits(t):bits, n:bits>>
}

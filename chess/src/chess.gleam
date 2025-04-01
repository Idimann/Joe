import bit_board

pub fn main() {
  let bb =
    bit_board.new()
    |> bit_board.switch_bit(0)
    |> bit_board.switch_bit(8)
    |> bit_board.switch_bit(16)
    |> bit_board.switch_bit(24)

  let b0 =
    bit_board.new()
    |> bit_board.switch_bit(0)

  let b8 =
    bit_board.new()
    |> bit_board.switch_bit(8)

  echo bit_board.without(bb, [b0, b8])
}

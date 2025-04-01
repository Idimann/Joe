import bit_board

//Kings are bit_board.without($(color), [pawns, knights, diags, lines])
pub type Board {
  Board(
    white: bit_board.Board,
    black: bit_board.Board,
    pawns: bit_board.Board,
    knights: bit_board.Board,
    diags: bit_board.Board,
    lines: bit_board.Board,
  )
}

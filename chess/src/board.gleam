import bit_board
import gleam/int
import gleam/option
import gleam/string
import square

pub type Board {
  Board(
    our: bit_board.Board,
    their: bit_board.Board,
    pawns: bit_board.Board,
    knights: bit_board.Board,
    diags: bit_board.Board,
    lines: bit_board.Board,
  )
}

pub fn o_king(b: Board) -> square.Square {
  // If there's no king we can crash (That really shouldn't happen)
  let assert option.Some(ret) =
    bit_board.without(b.our, [b.pawns, b.knights, b.diags, b.lines])
    |> bit_board.get_first()

  ret
}

pub fn t_king(b: Board) -> square.Square {
  // If there's no king we can crash (That really shouldn't happen)
  let assert option.Some(ret) =
    bit_board.without(b.their, [b.pawns, b.knights, b.diags, b.lines])
    |> bit_board.get_first()

  ret
}

pub fn en_passant(b: Board) -> option.Option(square.Square) {
  bit_board.without(b.pawns, [b.our, b.their])
  |> bit_board.get_first()
}

pub fn empty() -> Board {
  Board(
    our: bit_board.new(),
    their: bit_board.new(),
    pawns: bit_board.new(),
    knights: bit_board.new(),
    diags: bit_board.new(),
    lines: bit_board.new(),
  )
}

fn r_from_fen_main(b: Board, l: List(String), pos: square.Square) -> Board {
  case square.is_valid(pos) {
    True ->
      case l {
        [] -> b
        [head, ..tail] -> {
          case head {
            "/" -> r_from_fen_main(b, tail, pos) //{ pos / 8 } * 8)
            x ->
              case x {
                "r" ->
                  r_from_fen_main(
                    Board(
                      our: b.our,
                      their: bit_board.switch_bit(b.their, pos),
                      pawns: b.pawns,
                      knights: b.knights,
                      diags: b.diags,
                      lines: bit_board.switch_bit(b.lines, pos),
                    ),
                    tail,
                    pos - 1,
                  )
                "R" ->
                  r_from_fen_main(
                    Board(
                      our: bit_board.switch_bit(b.our, pos),
                      their: b.their,
                      pawns: b.pawns,
                      knights: b.knights,
                      diags: b.diags,
                      lines: bit_board.switch_bit(b.lines, pos),
                    ),
                    tail,
                    pos - 1,
                  )
                "n" ->
                  r_from_fen_main(
                    Board(
                      our: b.our,
                      their: bit_board.switch_bit(b.their, pos),
                      pawns: b.pawns,
                      knights: bit_board.switch_bit(b.knights, pos),
                      diags: b.diags,
                      lines: b.lines,
                    ),
                    tail,
                    pos - 1,
                  )
                "N" ->
                  r_from_fen_main(
                    Board(
                      our: bit_board.switch_bit(b.our, pos),
                      their: b.their,
                      pawns: b.pawns,
                      knights: bit_board.switch_bit(b.knights, pos),
                      diags: b.diags,
                      lines: b.lines,
                    ),
                    tail,
                    pos - 1,
                  )
                "b" ->
                  r_from_fen_main(
                    Board(
                      our: b.our,
                      their: bit_board.switch_bit(b.their, pos),
                      pawns: b.pawns,
                      knights: b.knights,
                      diags: bit_board.switch_bit(b.diags, pos),
                      lines: b.lines,
                    ),
                    tail,
                    pos - 1,
                  )
                "B" ->
                  r_from_fen_main(
                    Board(
                      our: bit_board.switch_bit(b.our, pos),
                      their: b.their,
                      pawns: b.pawns,
                      knights: b.knights,
                      diags: bit_board.switch_bit(b.diags, pos),
                      lines: b.lines,
                    ),
                    tail,
                    pos - 1,
                  )
                "k" ->
                  r_from_fen_main(
                    Board(
                      our: b.our,
                      their: bit_board.switch_bit(b.their, pos),
                      pawns: b.pawns,
                      knights: b.knights,
                      diags: b.diags,
                      lines: b.lines,
                    ),
                    tail,
                    pos - 1,
                  )
                "K" ->
                  r_from_fen_main(
                    Board(
                      our: bit_board.switch_bit(b.our, pos),
                      their: b.their,
                      pawns: b.pawns,
                      knights: b.knights,
                      diags: b.diags,
                      lines: b.lines,
                    ),
                    tail,
                    pos - 1,
                  )
                "q" ->
                  r_from_fen_main(
                    Board(
                      our: b.our,
                      their: bit_board.switch_bit(b.their, pos),
                      pawns: b.pawns,
                      knights: b.knights,
                      diags: bit_board.switch_bit(b.diags, pos),
                      lines: bit_board.switch_bit(b.lines, pos),
                    ),
                    tail,
                    pos - 1,
                  )
                "Q" ->
                  r_from_fen_main(
                    Board(
                      our: bit_board.switch_bit(b.our, pos),
                      their: b.their,
                      pawns: b.pawns,
                      knights: b.knights,
                      diags: bit_board.switch_bit(b.diags, pos),
                      lines: bit_board.switch_bit(b.lines, pos),
                    ),
                    tail,
                    pos - 1,
                  )
                "p" ->
                  r_from_fen_main(
                    Board(
                      our: b.our,
                      their: bit_board.switch_bit(b.their, pos),
                      pawns: bit_board.switch_bit(b.pawns, pos),
                      knights: b.knights,
                      diags: b.diags,
                      lines: b.lines,
                    ),
                    tail,
                    pos - 1,
                  )
                "P" ->
                  r_from_fen_main(
                    Board(
                      our: bit_board.switch_bit(b.our, pos),
                      their: b.their,
                      pawns: bit_board.switch_bit(b.pawns, pos),
                      knights: b.knights,
                      diags: b.diags,
                      lines: b.lines,
                    ),
                    tail,
                    pos - 1,
                  )
                n ->
                  case int.parse(n) {
                    Ok(x) -> r_from_fen_main(b, tail, pos - x)
                    Error(_) -> r_from_fen_main(b, tail, pos - 1)
                  }
              }
          }
        }
      }

    False -> b
  }
}

fn from_fen_main(b: Board, l: List(String)) -> Board {
  //We assume we're iterating from the white perspective here
  //If it tourns out we aren't, we just flip the board
  r_from_fen_main(b, l, 63)
}

fn from_fen_who(b: Board, w: String) -> Board {
  b
}

fn from_fen_castling(b: Board, l: List(String)) -> Board {
  b
}

fn from_fen_en_passant(b: Board, s: String) -> Board {
  b
}

pub fn from_fen(f: String) -> option.Option(Board) {
  case string.split(f, " ") {
    [main, who, castling, en_passant] -> {
      option.Some(
        empty()
        |> from_fen_main(string.split(main, ""))
        |> from_fen_who(who)
        |> from_fen_castling(string.split(castling, ""))
        |> from_fen_en_passant(en_passant),
      )
    }
    _ -> option.None
  }
}

pub fn format(b: Board) -> String {
  [
    "Our Pieces: " <> bit_board.format(b.our) <> "\n\n",
    "Their Pieces: " <> bit_board.format(b.their) <> "\n\n",
    "Pawns: " <> bit_board.format(b.pawns) <> "\n\n",
    "Knights: " <> bit_board.format(b.knights) <> "\n\n",
    "Diags: " <> bit_board.format(b.diags) <> "\n\n",
    "Lines: " <> bit_board.format(b.lines),
  ]
  |> string.join("")
}

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
    white: Bool,
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
    white: True,
  )
}

fn r_from_fen_main(b: Board, l: List(String), pos: square.Square) -> Board {
  case square.is_valid(pos) {
    True ->
      case l {
        [] -> b
        [head, ..tail] -> {
          case head {
            "/" -> r_from_fen_main(b, tail, pos)
            //{ pos / 8 } * 8)
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
                      white: b.white,
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
  let white = case w {
    "w" -> True
    "b" -> False
    _ -> b.white
  }
  let rev = fn(x) {
    case white {
      True -> x
      False -> bit_board.mirror(x)
    }
  }

  Board(
    our: rev(b.our),
    their: rev(b.their),
    pawns: rev(b.pawns),
    knights: rev(b.knights),
    diags: rev(b.diags),
    lines: rev(b.lines),
    white: white,
  )
}

fn from_fen_castling(b: Board, l: List(String)) -> Board {
  b
}

fn from_fen_en_passant(b: Board, s: String) -> Board {
  b
}

pub fn from_fen(f: String) -> option.Option(Board) {
  case string.split(f, " ") {
    [main, who, castling, en_passant, ..] -> {
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

pub fn pretty_print(b: Board) -> String {
  bit_board.iterate_collect_reverse(
    bit_board.new_filled(),
    "",
    fn(_: bit_board.Board, so: square.Square) {
      let check = fn(x) { bit_board.check_bit(x, so) }
      let piece = case check(b.pawns) {
        True -> "P"
        False ->
          case check(b.knights) {
            True -> "N"
            False ->
              case check(b.diags) {
                True ->
                  case check(b.lines) {
                    True -> "Q"
                    False -> "B"
                  }
                False ->
                  case check(b.lines) {
                    True -> "R"
                    False -> " "
                  }
              }
          }
      }
      let who = case check(b.our) {
        True -> 1
        False ->
          case check(b.their) {
            True -> -1
            False -> 0
          }
      }

      let str = case who {
        1 ->
          case piece {
            " " -> "K"
            x -> x
          }
        -1 ->
          case piece {
            " " -> "k"
            x -> string.lowercase(x)
          }
        _ -> " "
      }

      case 7 - so % 8 {
        7 -> str <> "\n"
        _ -> str
      }
    },
  )
  |> string.join("")
}

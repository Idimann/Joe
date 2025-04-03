import bit_board
import gleam/int
import gleam/option
import gleam/string
import square

///The first two bits mean our king-/queenside castling
///The last two bits mean their king-/queenside castling
pub type Castling =
  BitArray

pub type Board {
  Board(
    our: bit_board.Board,
    their: bit_board.Board,
    pawns: bit_board.Board,
    knights: bit_board.Board,
    diags: bit_board.Board,
    lines: bit_board.Board,
    white: Bool,
    mirror: Bool,
    castling: Castling,
  )
}

pub fn new_castle() -> Castling {
  <<0:4>>
}

pub fn mirror_castle(c: Castling) -> Castling {
  let assert <<ok:1-bits, oq:1-bits, tk:1-bits, tq:1-bits>> = c

  <<tk:bits, tq:bits, ok:bits, oq:bits>>
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
    mirror: False,
    castling: new_castle(),
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
                      mirror: b.mirror,
                      castling: b.castling,
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
  //We need to flip here because we are iterating backwards
  r_from_fen_main(b, l, 63) |> mirror_h()
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
      False -> x |> bit_board.mirror() |> bit_board.mirror_h()
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
    mirror: !white,
    castling: case white {
      True -> b.castling
      False -> mirror_castle(b.castling)
    },
  )
}

fn from_fen_castling(b: Board, l: List(String)) -> Board {
  case l {
    [] -> b
    [head, ..tail] -> {
      from_fen_castling(
        Board(
          our: b.our,
          their: b.their,
          pawns: b.pawns,
          knights: b.knights,
          diags: b.diags,
          lines: b.lines,
          white: b.white,
          mirror: b.mirror,
          castling: {
            let assert <<ok:1-bits, oq:1-bits, tk:1-bits, tq:1-bits>> =
              b.castling

            case head {
              "K" -> <<1:1, oq:bits, tk:bits, tq:bits>>
              "Q" -> <<ok:bits, 1:1, tk:bits, tq:bits>>
              "k" -> <<ok:bits, oq:bits, 1:1, tq:bits>>
              "q" -> <<ok:bits, oq:bits, tk:bits, 1:1>>
              _ -> b.castling
            }
          },
        ),
        tail,
      )
    }
  }
}

fn from_fen_en_passant(b: Board, s: String) -> Board {
  case square.from_string(s) {
    option.Some(x) ->
      Board(
        our: b.our,
        their: b.their,
        pawns: bit_board.switch_bit(b.pawns, x),
        knights: b.knights,
        diags: b.diags,
        lines: b.lines,
        white: b.white,
        mirror: b.mirror,
        castling: b.castling,
      )
    option.None -> b
  }
}

pub fn from_fen(f: String) -> option.Option(Board) {
  case string.split(f, " ") {
    [main, who, castling, en_passant, ..] -> {
      option.Some(
        empty()
        |> from_fen_main(string.split(main, ""))
        |> from_fen_castling(string.split(castling, ""))
        |> from_fen_en_passant(en_passant)
        |> from_fen_who(who),
      )
    }
    _ -> option.None
  }
}

pub fn mirror(b: Board) -> Board {
  Board(
    our: bit_board.mirror(b.our),
    their: bit_board.mirror(b.their),
    pawns: bit_board.mirror(b.pawns),
    knights: bit_board.mirror(b.knights),
    diags: bit_board.mirror(b.diags),
    lines: bit_board.mirror(b.lines),
    white: !b.white,
    mirror: b.mirror,
    castling: mirror_castle(b.castling),
  )
}

pub fn mirror_h(b: Board) -> Board {
  Board(
    our: bit_board.mirror_h(b.our),
    their: bit_board.mirror_h(b.their),
    pawns: bit_board.mirror_h(b.pawns),
    knights: bit_board.mirror_h(b.knights),
    diags: bit_board.mirror_h(b.diags),
    lines: bit_board.mirror_h(b.lines),
    white: b.white,
    mirror: !b.mirror,
    castling: b.castling,
  )
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
  bit_board.iterate_collect_linewise(
    bit_board.new_filled(),
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

      case so % 8 {
        7 -> str <> "\n"
        _ -> str <> " "
      }
    },
  )
  |> string.join("")
}

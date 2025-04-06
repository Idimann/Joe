import gleam/list
import gleam/option
import square

//The bool is true if it's an enemy piece
pub type Value {
  Empty
  Pawn(Bool)
  Knight(Bool)
  Bishop(Bool)
  Rook(Bool)
  Queen(Bool)
  King(Bool)
  EnPassant
}

pub type Board =
  BitArray

pub fn new() -> Board {
  <<0:size({ 64 * 4 })>>
}

pub fn to_bits(s: Value) -> BitArray {
  case s {
    Empty -> <<0:1, 0:1, 0:1, 0:1>>
    Pawn(v) -> <<
      case v {
        False -> 0
        True -> 1
      }:1,
      0:1,
      0:1,
      1:1,
    >>
    Knight(v) -> <<
      case v {
        False -> 0
        True -> 1
      }:1,
      0:1,
      1:1,
      0:1,
    >>
    Bishop(v) -> <<
      case v {
        False -> 0
        True -> 1
      }:1,
      0:1,
      1:1,
      1:1,
    >>
    Rook(v) -> <<
      case v {
        False -> 0
        True -> 1
      }:1,
      1:1,
      0:1,
      0:1,
    >>
    Queen(v) -> <<
      case v {
        False -> 0
        True -> 1
      }:1,
      1:1,
      0:1,
      1:1,
    >>
    King(v) -> <<
      case v {
        False -> 0
        True -> 1
      }:1,
      1:1,
      1:1,
      0:1,
    >>
    EnPassant -> <<1:1, 1:1, 1:1, 1:1>>
  }
}

pub fn from_bits(b: BitArray) -> option.Option(Value) {
  case b {
    <<0:1, 0:1, 0:1, 0:1>> -> option.Some(Empty)
    <<v:1, 0:1, 0:1, 1:1>> ->
      option.Some(
        Pawn(case v {
          0 -> False
          _ -> True
        }),
      )
    <<v:1, 0:1, 1:1, 0:1>> ->
      option.Some(
        Knight(case v {
          0 -> False
          _ -> True
        }),
      )
    <<v:1, 0:1, 1:1, 1:1>> ->
      option.Some(
        Bishop(case v {
          0 -> False
          _ -> True
        }),
      )
    <<v:1, 1:1, 0:1, 0:1>> ->
      option.Some(
        Rook(case v {
          0 -> False
          _ -> True
        }),
      )
    <<v:1, 1:1, 0:1, 1:1>> ->
      option.Some(
        Queen(case v {
          0 -> False
          _ -> True
        }),
      )
    <<v:1, 1:1, 1:1, 0:1>> ->
      option.Some(
        King(case v {
          0 -> False
          _ -> True
        }),
      )
    <<1:1, 1:1, 1:1, 1:1>> -> option.Some(EnPassant)
    _ -> option.None
  }
}

pub fn value_to_string(v: Value, w: Bool) -> String {
  case v {
    Empty -> " "
    Pawn(v) ->
      case v == w {
        True -> "p"
        False -> "P"
      }
    Knight(v) ->
      case v == w {
        True -> "n"
        False -> "N"
      }
    Bishop(v) ->
      case v == w {
        True -> "b"
        False -> "B"
      }
    Rook(v) ->
      case v == w {
        True -> "r"
        False -> "R"
      }
    Queen(v) ->
      case v == w {
        True -> "q"
        False -> "Q"
      }
    King(v) ->
      case v == w {
        True -> "k"
        False -> "K"
      }
    EnPassant -> "E"
  }
}

pub fn set(b: Board, s: square.Square, t: Value) -> Board {
  let bf = s * 4
  let af = { 63 - s } * 4

  //63 cause we cut the one we're replacing
  let assert <<p:size(bf)-bits, _:size(4), n:size(af)-bits>> = b

  <<p:bits, to_bits(t):bits, n:bits>>
}

pub fn get(b: Board, s: square.Square) -> Value {
  let bf = s * 4
  let af = { 63 - s } * 4
  //63 cause we cut the one we're looking for

  let assert <<_:size(bf)-bits, v:size(4)-bits, _:size(af)-bits>> = b

  let assert option.Some(ret) = from_bits(v)
  ret
}

pub fn to_list(b: Board) -> List(Value) {
  case b {
    <<v:size(4)-bits, rest:bits>> -> {
      let assert option.Some(vl) = from_bits(v)
      list.prepend(to_list(rest), vl)
    }
    _ -> []
  }
}

fn r_iter(
  b: Board,
  func: fn(square.Square, Value) -> option.Option(a),
  collect: List(a),
  sq: square.Square,
) -> List(a) {
  case b {
    <<v:size(4)-bits, rest:bits>> -> {
      let assert option.Some(vl) = from_bits(v)
      r_iter(
        rest,
        func,
        case func(sq, vl) {
          option.Some(x) -> list.prepend(collect, x)
          option.None -> collect
        },
        sq + 1,
      )
    }
    _ -> collect
  }
}

pub fn iter(
  b: Board,
  func: fn(square.Square, Value) -> option.Option(a),
) -> List(a) {
  r_iter(b, func, [], 0)
}

pub fn iter_pieces(
  b: Board,
  func: fn(square.Square, Value) -> option.Option(a),
) -> List(a) {
  r_iter(
    b,
    fn(sq, v) {
      case v {
        Empty -> option.None
        EnPassant -> option.None
        _ -> func(sq, v)
      }
    },
    [],
    0,
  )
}

fn mirror_square(i: BitArray) -> BitArray {
  let assert option.Some(v) = from_bits(i)

  to_bits(case v {
    Empty -> Empty
    Pawn(v) -> Pawn(!v)
    Knight(v) -> Knight(!v)
    Bishop(v) -> Bishop(!v)
    Rook(v) -> Rook(!v)
    Queen(v) -> Queen(!v)
    King(v) -> King(!v)
    EnPassant -> EnPassant
  })
}

fn mirror_line(l: BitArray) -> BitArray {
  let sq = 4

  let assert <<
    v0:size(sq)-bits,
    v1:size(sq)-bits,
    v2:size(sq)-bits,
    v3:size(sq)-bits,
    v4:size(sq)-bits,
    v5:size(sq)-bits,
    v6:size(sq)-bits,
    v7:size(sq)-bits,
  >> = l

  <<
    mirror_square(v0):bits,
    mirror_square(v1):bits,
    mirror_square(v2):bits,
    mirror_square(v3):bits,
    mirror_square(v4):bits,
    mirror_square(v5):bits,
    mirror_square(v6):bits,
    mirror_square(v7):bits,
  >>
}

pub fn mirror(b: Board) -> Board {
  let line = 4 * 8

  let assert <<
    v0:size(line)-bits,
    v1:size(line)-bits,
    v2:size(line)-bits,
    v3:size(line)-bits,
    v4:size(line)-bits,
    v5:size(line)-bits,
    v6:size(line)-bits,
    v7:size(line)-bits,
  >> = b

  <<
    mirror_line(v7):bits,
    mirror_line(v6):bits,
    mirror_line(v5):bits,
    mirror_line(v4):bits,
    mirror_line(v3):bits,
    mirror_line(v2):bits,
    mirror_line(v1):bits,
    mirror_line(v0):bits,
  >>
}

fn mirror_h_line(l: BitArray) -> BitArray {
  let sq = 4

  let assert <<
    v0:size(sq)-bits,
    v1:size(sq)-bits,
    v2:size(sq)-bits,
    v3:size(sq)-bits,
    v4:size(sq)-bits,
    v5:size(sq)-bits,
    v6:size(sq)-bits,
    v7:size(sq)-bits,
  >> = l

  <<v7:bits, v6:bits, v5:bits, v4:bits, v3:bits, v2:bits, v1:bits, v0:bits>>
}

pub fn mirror_h(b: Board) -> Board {
  let line = 4 * 8

  let assert <<
    v0:size(line)-bits,
    v1:size(line)-bits,
    v2:size(line)-bits,
    v3:size(line)-bits,
    v4:size(line)-bits,
    v5:size(line)-bits,
    v6:size(line)-bits,
    v7:size(line)-bits,
  >> = b

  <<
    mirror_h_line(v0):bits,
    mirror_h_line(v1):bits,
    mirror_h_line(v2):bits,
    mirror_h_line(v3):bits,
    mirror_h_line(v4):bits,
    mirror_h_line(v5):bits,
    mirror_h_line(v6):bits,
    mirror_h_line(v7):bits,
  >>
}

pub fn move_piece(b: Board, f: square.Square, t: square.Square) -> Board {
  let x = get(b, f)

  b |> set(f, Empty) |> set(t, x)
}

import gleam/bit_array
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import square

pub type Board =
  BitArray

pub fn new() -> Board {
  <<0:64>>
}

pub fn new_filled() -> Board {
  <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>
}

pub fn check_valid(b: Board) {
  let assert <<_:64>> = b
}

pub fn is_valid(b: Board) -> Bool {
  case bit_array.bit_size(b) {
    64 -> True
    _ -> False
  }
}

pub fn check_bit(b: Board, s: square.Square) -> Bool {
  case b {
    <<_:size(s), 1:1, _:bits>> -> True
    _ -> False
  }
}

pub fn switch_bit(b: Board, s: square.Square) -> Board {
  let assert <<first:size(s)-bits, v:1, second:bits>> = b
  <<
    first:bits,
    case v {
      1 -> 0
      _ -> 1
    }:1,
    second:bits,
  >>
}

pub fn assign_bit(b: Board, s: square.Square, v: Int) -> Board {
  let assert <<first:size(s)-bits, _:1, second:bits>> = b
  <<
    first:bits,
    case v {
      0 -> 0
      _ -> 1
    }:1,
    second:bits,
  >>
}

pub fn from_square(s: square.Square) -> Board {
  switch_bit(new(), s)
}

fn r_get_first(b: Board, s: square.Square) -> option.Option(square.Square) {
  case square.is_valid(s) {
    True ->
      case check_bit(b, s) {
        True -> option.Some(s)
        False -> r_get_first(b, s + 1)
      }

    False -> option.None
  }
}

pub fn get_first(b: Board) -> option.Option(square.Square) {
  r_get_first(b, 0)
}

fn r_iterate(
  b: Board,
  func: fn(Board, square.Square) -> Board,
  s: square.Square,
) -> Board {
  case square.is_valid(s) {
    True ->
      r_iterate(
        case check_bit(b, s) {
          True -> func(b, s)
          False -> b
        },
        func,
        s + 1,
      )
    False -> b
  }
}

pub fn iterate(b: Board, func: fn(Board, square.Square) -> Board) -> Board {
  r_iterate(b, func, 0)
}

fn r_and(b: Board, list: List(Board)) -> Board {
  case list {
    [] -> b
    [head, ..tail] ->
      r_and(
        iterate(b, fn(bo, sq) {
          case check_bit(head, sq) {
            True -> bo
            False -> assign_bit(bo, sq, 0)
          }
        }),
        tail,
      )
  }
}

fn r_or(b: Board, list: List(Board)) -> Board {
  case list {
    [] -> b
    [head, ..tail] ->
      r_or(
        iterate(new_filled(), fn(bo, so) {
          assign_bit(bo, so, case check_bit(b, so) || check_bit(head, so) {
            True -> 1
            False -> 0
          })
        }),
        tail,
      )
  }
}

pub fn and(list: List(Board)) -> Board {
  r_and(new_filled(), list)
}

pub fn or(list: List(Board)) -> Board {
  r_or(new(), list)
}

pub fn neg(b: Board) -> Board {
  iterate(new_filled(), fn(bo, so) {
    assign_bit(bo, so, case check_bit(b, so) {
      True -> 0
      False -> 1
    })
  })
}

pub fn without(b: Board, l: List(Board)) -> Board {
  or(l)
  |> neg()
  |> fn(e) { list.prepend([], e) }
  |> list.prepend(b)
  |> and()
}

fn r_iterate_collect(
  b: Board,
  func: fn(Board, square.Square) -> a,
  base: List(a),
  non_reversed: Bool,
  s: square.Square,
) -> List(a) {
  case square.is_valid(s) {
    True ->
      case check_bit(b, s) {
        True ->
          r_iterate_collect(
            b,
            func,
            list.prepend(base, func(b, s)),
            non_reversed,
            case non_reversed {
              True -> s - 1
              False -> s + 1
            },
          )
        False ->
          r_iterate_collect(b, func, base, non_reversed, case non_reversed {
            True -> s - 1
            False -> s + 1
          })
      }
    False -> base
  }
}

pub fn iterate_collect(b: Board, func: fn(Board, square.Square) -> a) -> List(a) {
  //I know passing in True and 63 might seem weird, but it's correct cause of tail call
  r_iterate_collect(b, func, [], True, 63)
}

pub fn iterate_collect_reverse(
  b: Board,
  func: fn(Board, square.Square) -> a,
) -> List(a) {
  r_iterate_collect(b, func, [], False, 0)
}

fn r_iterate_collect_linewise(
  b: Board,
  func: fn(Board, square.Square) -> a,
  base: List(a),
  s: square.Square,
) -> List(a) {
  case square.is_valid(s) {
    True ->
      case check_bit(b, s) {
        True ->
          r_iterate_collect_linewise(
            b,
            func,
            list.prepend(base, func(b, s)),
            case s % 8 {
              7 -> s - 15
              _ -> s + 1
            },
          )
        False ->
          r_iterate_collect_linewise(b, func, base, case s % 8 {
            7 -> s - 15
            _ -> s + 1
          })
      }
    False -> base
  }
}

pub fn iterate_collect_linewise(
  b: Board,
  func: fn(Board, square.Square) -> a,
) -> List(a) {
  r_iterate_collect_linewise(b, func, [], 56)
  |> list.reverse()
}

fn r_iterate_collect_list(
  b: Board,
  func: fn(Board, square.Square) -> List(a),
  base: List(a),
  non_reversed: Bool,
  s: square.Square,
) -> List(a) {
  case square.is_valid(s) {
    True ->
      case check_bit(b, s) {
        True ->
          r_iterate_collect_list(
            b,
            func,
            list.append(base, func(b, s)),
            non_reversed,
            case non_reversed {
              True -> s - 1
              False -> s + 1
            },
          )
        False ->
          r_iterate_collect_list(
            b,
            func,
            base,
            non_reversed,
            case non_reversed {
              True -> s - 1
              False -> s + 1
            },
          )
      }
    False -> base
  }
}

pub fn iterate_collect_list(
  b: Board,
  func: fn(Board, square.Square) -> List(a),
) -> List(a) {
  //I know passing in True and 63 might seem weird, but it's correct cause of tail call
  r_iterate_collect_list(b, func, [], True, 63)
}

pub fn format(b: Board) -> String {
  iterate_collect(b, fn(_, s) { "|" <> int.to_string(s) <> "| " })
  |> string.join("")
}

pub fn mirror(b: Board) -> Board {
  let assert <<
    r0:size(8)-bits,
    r1:size(8)-bits,
    r2:size(8)-bits,
    r3:size(8)-bits,
    r4:size(8)-bits,
    r5:size(8)-bits,
    r6:size(8)-bits,
    r7:size(8)-bits,
  >> = b

  <<r7:bits, r6:bits, r5:bits, r4:bits, r3:bits, r2:bits, r1:bits, r0:bits>>
}

///This takes in a 1 byte bit array
fn mirror_1d(a: BitArray) -> BitArray {
  let assert <<
    r0:size(1)-bits,
    r1:size(1)-bits,
    r2:size(1)-bits,
    r3:size(1)-bits,
    r4:size(1)-bits,
    r5:size(1)-bits,
    r6:size(1)-bits,
    r7:size(1)-bits,
  >> = a

  <<r7:bits, r6:bits, r5:bits, r4:bits, r3:bits, r2:bits, r1:bits, r0:bits>>
}

pub fn mirror_h(b: Board) -> Board {
  let assert <<
    r0:size(8)-bits,
    r1:size(8)-bits,
    r2:size(8)-bits,
    r3:size(8)-bits,
    r4:size(8)-bits,
    r5:size(8)-bits,
    r6:size(8)-bits,
    r7:size(8)-bits,
  >> = b

  <<
    mirror_1d(r0):bits,
    mirror_1d(r1):bits,
    mirror_1d(r2):bits,
    mirror_1d(r3):bits,
    mirror_1d(r4):bits,
    mirror_1d(r5):bits,
    mirror_1d(r6):bits,
    mirror_1d(r7):bits,
  >>
}

pub fn pretty_print(b: Board) -> String {
  iterate_collect_linewise(new_filled(), fn(_: Board, so: square.Square) {
    let str = case check_bit(b, so) {
      True -> "x"
      False -> " "
    }
    case so % 8 {
      7 -> str <> "\n"
      _ -> str <> " "
    }
  })
  |> string.join("")
}

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
  base: a,
  s: square.Square,
) -> List(a) {
  case square.is_valid(s) {
    True ->
      case check_bit(b, s) {
        True ->
          list.prepend(r_iterate_collect(b, func, base, s + 1), func(b, s))
        False -> r_iterate_collect(b, func, base, s + 1)
      }
    False -> [base]
  }
}

pub fn iterate_collect(
  b: Board,
  func: fn(Board, square.Square) -> a,
  base: a,
) -> List(a) {
  r_iterate_collect(b, func, base, 0)
}

pub fn format(b: Board) -> String {
  iterate_collect(b, fn(_, s) { "|" <> int.to_string(s) <> "| " }, "")
  |> string.join("")
}

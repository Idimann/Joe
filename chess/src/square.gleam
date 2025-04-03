import gleam/int
import gleam/option
import gleam/string

pub type Square =
  Int

pub fn is_valid(s: Square) -> Bool {
  s >= 0 && s < 64
}

pub fn mirror(s: Square) -> Square {
  let x = s % 8
  let y = s - s % 8

  // I know 56 might seem weird here
  { 56 - y } + x
}

pub fn mirror_h(s: Square) -> Square {
  let x = s % 8
  let y = s - s % 8

  // 7 is correct here
  { 7 - x } + y
}

pub fn to_string(s: Square, mir: Bool) -> String {
  let x = case mir {
    True -> 7 - { s % 8 }
    False -> s % 8
  }
  let y = case mir {
    True -> 7 - { s - s % 8 } / 8
    False -> { s - s % 8 } / 8
  }
  let pref = case x {
    0 -> "a"
    1 -> "b"
    2 -> "c"
    3 -> "d"
    4 -> "e"
    5 -> "f"
    6 -> "g"
    7 -> "h"
    _ -> ""
  }

  pref <> int.to_string(y + 1)
}

pub fn from_string(i: String) -> option.Option(Square) {
  case string.split(i, "") {
    [x, y] -> {
      case int.parse(y) {
        Ok(y) ->
          case x {
            "a" -> option.Some({ y - 1 } * 8 + 0)
            "b" -> option.Some({ y - 1 } * 8 + 1)
            "c" -> option.Some({ y - 1 } * 8 + 2)
            "d" -> option.Some({ y - 1 } * 8 + 3)
            "e" -> option.Some({ y - 1 } * 8 + 4)
            "f" -> option.Some({ y - 1 } * 8 + 5)
            "g" -> option.Some({ y - 1 } * 8 + 6)
            "h" -> option.Some({ y - 1 } * 8 + 7)
            _ -> option.None
          }
        Error(_) -> option.None
      }
    }
    _ -> option.None
  }
}

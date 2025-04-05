import gleam/list

fn r_each_array(size: Int, func: fn(BitArray) -> a, prefix: BitArray) -> List(a) {
  case size {
    0 -> [func(prefix)]
    _ ->
      list.append(
        r_each_array(size - 1, func, <<prefix:bits, 0:1>>),
        r_each_array(size - 1, func, <<prefix:bits, 1:1>>),
      )
  }
}

pub fn each_array(size: Int, func: fn(BitArray) -> a) -> List(a) {
  r_each_array(size, func, <<>>)
}

fn r_each_bit(size: Int, func: fn(BitArray, Int) -> a, pos: Int) -> List(a) {
  case pos == size {
    True -> []
    _ ->
      list.prepend(
        r_each_bit(size, func, pos + 1),
        func(<<0:size(pos), 1:1, 0:size({ size - pos - 1 })>>, pos),
      )
  }
}

pub fn each_bit(size: Int, func: fn(BitArray, Int) -> a) -> List(a) {
  r_each_bit(size, func, 0)
}

pub fn pretty(b: BitArray) -> String {
  case b {
    <<v:1, rest:bits>> ->
      case v {
        0 -> "0"
        _ -> "1"
      }
      <> pretty(rest)
    _ -> ""
  }
}

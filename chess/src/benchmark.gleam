pub fn repeat(n: Int, f: fn() -> _) {
  case n {
    0 -> Nil
    _ -> {
      f()
      repeat(n - 1, f)
    }
  }
}

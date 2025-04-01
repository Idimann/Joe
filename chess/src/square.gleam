pub type Square = Int

pub fn is_valid(s: Square) -> Bool {
  s >= 0 && s < 64
}

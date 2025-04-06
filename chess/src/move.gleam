import gleam/option
import square

pub type PromType {
  Knight
  Bishop
  Rook
  Queen
}

pub type CastleType {
  Kingside
  Queenside
}

pub type Move {
  ///The first is square is 'from', the second one is 'to'
  Normal(square.Square, square.Square)
  Castle(CastleType)
  EnPassant(square.Square)
  Promotion(square.Square, square.Square, PromType)
}

pub fn to_string(m: Move, mir: Bool) -> String {
  case m {
    Normal(f, t) -> square.to_string(f, mir) <> square.to_string(t, mir)
    Castle(t) ->
      case t {
        Kingside -> "o"
        Queenside -> "O"
      }
    EnPassant(f) -> square.to_string(f, mir) <> "+"
    Promotion(f, t, ty) ->
      square.to_string(f, mir)
      <> square.to_string(t, mir)
      <> "="
      <> case ty {
        Knight -> "N"
        Bishop -> "B"
        Rook -> "R"
        Queen -> "Q"
      }
  }
}

pub fn normal(f: String, t: String) -> option.Option(Move) {
  case square.from_string(f), square.from_string(t) {
    option.Some(f), option.Some(t) -> option.Some(Normal(f, t))
    _, _ -> option.None
  }
}

pub fn en_passant(f: String) -> option.Option(Move) {
  case square.from_string(f) {
    option.Some(f) -> option.Some(EnPassant(f))
    _ -> option.None
  }
}

pub fn castle(x: CastleType) -> option.Option(Move) {
  option.Some(Castle(x))
}

pub fn promotion(f: String, t: String, x: PromType) -> option.Option(Move) {
  case square.from_string(f), square.from_string(t) {
    option.Some(f), option.Some(t) -> option.Some(Promotion(f, t, x))
    _, _ -> option.None
  }
}

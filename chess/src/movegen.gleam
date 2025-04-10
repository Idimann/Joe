import bit_board
import board
import gleam/dict
import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import move
import square
import tablegen

fn gen_pawn(
  b: board.Board,
  s: square.Square,
  at: tablegen.Table,
) -> List(move.Move) {
  let assert Ok(attacks) = dict.get(at, s)

  let sq = s + 8
  let main_m = case bit_board.get(b.board, sq) {
    bit_board.Empty -> {
      let y = { sq - sq % 8 } / 8

      case y {
        7 -> [
          move.Promotion(s, sq, move.Knight),
          move.Promotion(s, sq, move.Bishop),
          move.Promotion(s, sq, move.Rook),
          move.Promotion(s, sq, move.Queen),
        ]
        _ ->
          case y == 2, bit_board.get(b.board, sq + 8) {
            True, bit_board.Empty -> [
              move.Normal(s, sq),
              move.Normal(s, sq + 8),
            ]
            _, _ -> [move.Normal(s, sq)]
          }
      }
    }
    _ -> []
  }

  let attack_m =
    list.map(attacks, fn(sq) {
      case bit_board.get(b.board, sq) {
        bit_board.Pawn(True)
        | bit_board.Knight(True)
        | bit_board.Bishop(True)
        | bit_board.Rook(True)
        | bit_board.Queen(True) -> {
          let y = { sq - sq % 8 } / 8

          case y {
            7 -> [
              move.Promotion(s, sq, move.Knight),
              move.Promotion(s, sq, move.Bishop),
              move.Promotion(s, sq, move.Rook),
              move.Promotion(s, sq, move.Queen),
            ]
            _ -> [move.Normal(s, sq)]
          }
        }
        bit_board.EnPassant -> [move.EnPassant(s)]
        _ -> []
      }
    })

  attack_m |> list.flatten() |> list.append(main_m)
}

fn gen_knight_king(
  b: board.Board,
  s: square.Square,
  t: tablegen.Table,
) -> List(move.Move) {
  let assert Ok(main) = dict.get(t, s)

  main
  |> list.filter(fn(sq) {
    case bit_board.get(b.board, sq) {
      bit_board.Empty
      | bit_board.EnPassant
      | bit_board.Pawn(True)
      | bit_board.Knight(True)
      | bit_board.Bishop(True)
      | bit_board.Rook(True)
      | bit_board.Queen(True) -> True
      _ -> False
    }
  })
  |> list.map(fn(sq) { move.Normal(s, sq) })
}

fn get_line(
  b: bit_board.Board,
  pos: square.Square,
  s: square.Square,
  left: Bool,
  incr: Int,
) -> #(Bool, BitArray) {
  case { s < pos && left } || { s > pos && !left } {
    True -> {
      let func = fn(x) {
        let next =
          get_line(
            b,
            pos,
            case left {
              True -> s + incr
              False -> s - incr
            },
            left,
            incr,
          )

        let bit = case next.0 {
          True -> 1
          False -> x
        }

        case left {
          True -> <<bit:1, next.1:bits>>
          False -> <<next.1:bits, bit:1>>
        }
      }

      case bit_board.get(b, s) {
        bit_board.Empty | bit_board.EnPassant -> #(False, func(0))
        bit_board.Pawn(True)
        | bit_board.Knight(True)
        | bit_board.Bishop(True)
        | bit_board.Rook(True)
        | bit_board.Queen(True) -> #(False, func(1))
        _ -> #(True, func(0))
      }
    }
    False -> #(False, <<>>)
  }
}

fn collect_until(
  b: board.Board,
  s: square.Square,
  ss: List(square.Square),
  coll: List(move.Move),
) -> List(move.Move) {
  case ss {
    [] -> coll
    [head, ..tail] -> {
      let h_m = move.Normal(s, head)

      case bit_board.get(b.board, head) {
        bit_board.Empty | bit_board.EnPassant ->
          collect_until(b, s, tail, list.prepend(coll, h_m))
        bit_board.Pawn(v)
        | bit_board.Knight(v)
        | bit_board.Bishop(v)
        | bit_board.Rook(v)
        | bit_board.Queen(v)
        | bit_board.King(v) ->
          case v {
            True -> list.prepend(coll, h_m)
            False -> coll
          }
      }
    }
  }
}

pub fn gen_sliding(
  b: board.Board,
  s: square.Square,
  rows: tablegen.SlideTable,
  cols: tablegen.SlideTable,
) -> List(move.Move) {
  let assert Ok(#(row_f, row_s)) = dict.get(rows, s)
  let assert Ok(#(col_f, col_s)) = dict.get(cols, s)

  let row_fm = collect_until(b, s, row_f, [])
  let row_sm = collect_until(b, s, row_s, [])
  let col_fm = collect_until(b, s, col_f, [])
  let col_sm = collect_until(b, s, col_s, [])

  list.append(row_fm, row_sm) |> list.append(list.append(col_fm, col_sm))
}

pub fn gen_pseudo(b: board.Board, t: tablegen.Tables) -> List(move.Move) {
  bit_board.iter_pieces(b.board, fn(sq, vl) {
    case vl {
      bit_board.Pawn(False) -> gen_pawn(b, sq, t.pawns)
      bit_board.Knight(False) -> gen_knight_king(b, sq, t.knights)
      bit_board.Bishop(False) -> gen_sliding(b, sq, t.diags, t.o_diags)
      bit_board.Rook(False) -> gen_sliding(b, sq, t.rows, t.cols)
      bit_board.Queen(False) ->
        list.append(
          gen_sliding(b, sq, t.diags, t.o_diags),
          gen_sliding(b, sq, t.rows, t.cols),
        )
      bit_board.King(False) -> gen_knight_king(b, sq, t.kings)
      _ -> []
    }
  })
}

fn check_for(b: board.Board, l: List(square.Square), v: bit_board.Value) -> Bool {
  case l {
    [] -> False
    [head, ..tail] ->
      case bit_board.get(b.board, head) == v {
        True -> True
        False -> check_for(b, tail, v)
      }
  }
}

fn check_until(
  b: board.Board,
  l: List(square.Square),
  v: bit_board.Value,
  v2: bit_board.Value,
) -> Bool {
  case l {
    [] -> False
    [head, ..tail] -> {
      let got = bit_board.get(b.board, head)

      case got == v || got == v2 {
        True -> True
        False ->
          case got {
            bit_board.Empty | bit_board.EnPassant -> check_until(b, tail, v, v2)
            bit_board.Pawn(_)
            | bit_board.Knight(_)
            | bit_board.Bishop(_)
            | bit_board.Rook(_)
            | bit_board.Queen(_)
            | bit_board.King(_) -> False
          }
      }
    }
  }
}

pub fn in_check(b: board.Board, t: tablegen.Tables) -> Bool {
  let king = bit_board.find_king(b.board)

  let assert Ok(knights) = dict.get(t.knights, king)
  let assert Ok(pawns) = dict.get(t.r_pawns, king)
  let assert Ok(#(row_f, row_s)) = dict.get(t.rows, king)
  let assert Ok(#(col_f, col_s)) = dict.get(t.cols, king)
  let assert Ok(#(diag_f, diag_s)) = dict.get(t.diags, king)
  let assert Ok(#(o_diag_f, o_diag_s)) = dict.get(t.o_diags, king)

  check_for(b, knights, bit_board.Knight(False))
  || check_for(b, pawns, bit_board.Pawn(False))
  || check_until(b, row_f, bit_board.Rook(False), bit_board.Queen(False))
  || check_until(b, row_s, bit_board.Rook(False), bit_board.Queen(False))
  || check_until(b, col_f, bit_board.Rook(False), bit_board.Queen(False))
  || check_until(b, col_s, bit_board.Rook(False), bit_board.Queen(False))
  || check_until(b, diag_f, bit_board.Bishop(False), bit_board.Queen(False))
  || check_until(b, diag_s, bit_board.Bishop(False), bit_board.Queen(False))
  || check_until(b, o_diag_f, bit_board.Bishop(False), bit_board.Queen(False))
  || check_until(b, o_diag_s, bit_board.Bishop(False), bit_board.Queen(False))
}

pub fn under_attack(
  b: board.Board,
  t: tablegen.Tables,
  s: square.Square,
) -> Bool {
  let assert Ok(knights) = dict.get(t.knights, s)
  let assert Ok(pawns) = dict.get(t.r_pawns, s)
  let assert Ok(#(row_f, row_s)) = dict.get(t.rows, s)
  let assert Ok(#(col_f, col_s)) = dict.get(t.cols, s)
  let assert Ok(#(diag_f, diag_s)) = dict.get(t.diags, s)
  let assert Ok(#(o_diag_f, o_diag_s)) = dict.get(t.o_diags, s)

  check_for(b, knights, bit_board.Knight(True))
  || check_for(b, pawns, bit_board.Pawn(True))
  || check_until(b, row_f, bit_board.Rook(True), bit_board.Queen(True))
  || check_until(b, row_s, bit_board.Rook(True), bit_board.Queen(True))
  || check_until(b, col_f, bit_board.Rook(True), bit_board.Queen(True))
  || check_until(b, col_s, bit_board.Rook(True), bit_board.Queen(True))
  || check_until(b, diag_f, bit_board.Bishop(True), bit_board.Queen(True))
  || check_until(b, diag_s, bit_board.Bishop(True), bit_board.Queen(True))
  || check_until(b, o_diag_f, bit_board.Bishop(True), bit_board.Queen(True))
  || check_until(b, o_diag_s, bit_board.Bishop(True), bit_board.Queen(True))
}

pub fn gen(
  b: board.Board,
  t: tablegen.Tables,
) -> List(#(move.Move, board.Board)) {
  let castle_k = case b.mirror {
    False -> #([5, 6], [4, 5])
    True -> #([2, 1], [3, 2])
  }
  let castle_q = case b.mirror {
    False -> #([3, 2, 1], [4, 3])
    True -> #([4, 5, 6], [5, 6])
  }

  gen_pseudo(b, t)
  |> list.map(fn(m) { #(m, move.apply(b, m)) })
  |> case b.castling {
    <<1:1, _:bits>> -> fn(x) {
      case
        list.all(castle_k.0, fn(y) {
          case bit_board.get(b.board, y) {
            bit_board.Empty | bit_board.EnPassant -> True
            _ -> False
          }
        })
      {
        True ->
          case list.all(castle_k.1, fn(y) { !under_attack(b, t, y) }) {
            True -> {
              let m = move.Castle(move.Kingside)
              list.prepend(x, #(m, move.apply(b, m)))
            }
            False -> x
          }
        False -> x
      }
    }
    _ -> fn(x) { x }
  }
  |> case b.castling {
    <<_:1, 1:1, _:bits>> -> fn(x) {
      case
        list.all(castle_q.0, fn(y) {
          case bit_board.get(b.board, y) {
            bit_board.Empty | bit_board.EnPassant -> True
            _ -> False
          }
        })
      {
        True ->
          case list.all(castle_q.1, fn(y) { !under_attack(b, t, y) }) {
            True -> {
              let m = move.Castle(move.Queenside)
              list.prepend(x, #(m, move.apply(b, m)))
            }
            False -> x
          }
        False -> x
      }
    }
    _ -> fn(x) { x }
  }
  |> list.filter(fn(x) { !in_check(x.1, t) })
}

pub fn perft(b: board.Board, t: tablegen.Tables, n: Int) -> Int {
  case n {
    0 -> 1
    _ ->
      case
        gen(b, t)
        |> list.map(fn(p) { perft(p.1, t, n - 1) })
        |> list.reduce(fn(acc, x) { acc + x })
      {
        Ok(x) -> x
        Error(_) -> 0
      }
  }
}

pub fn perft_print(b: board.Board, t: tablegen.Tables, n: Int) {
  let pe =
    gen(b, t)
    |> list.map(fn(x) { #(x.0, perft(x.1, t, n - 1)) })

  pe
  |> list.map(fn(x) {
    move.to_string(x.0, b.mirror) <> ": " <> x.1 |> int.to_string()
  })
  |> list.each(io.println)

  let assert Ok(total) = list.reduce(pe, fn(acc, x) { #(acc.0, acc.1 + x.1) })

  {
    "Total: "
    <> total.1
    |> int.to_string()
  }
  |> io.println()
}

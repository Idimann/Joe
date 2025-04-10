import bit_board
import gleam/dict
import gleam/int
import gleam/list
import square

pub type Table =
  dict.Dict(square.Square, List(square.Square))

pub type SlideTable =
  dict.Dict(square.Square, #(List(square.Square), List(square.Square)))

pub type Tables {
  Tables(
    pawns: Table,
    r_pawns: Table,
    knights: Table,
    kings: Table,
    rows: SlideTable,
    cols: SlideTable,
    diags: SlideTable,
    o_diags: SlideTable,
  )
}

fn gen_pawn_attacks() -> Table {
  bit_board.iter_list(bit_board.new(), fn(sq, _) {
    let x = sq % 8

    case { sq - x } / 8 {
      7 -> [#(sq, [])]
      _ -> [
        #(sq, case x {
          0 -> [sq + 9]
          7 -> [sq + 7]
          _ -> [sq + 9, sq + 7]
        }),
      ]
    }
  })
  |> dict.from_list()
}

fn gen_r_pawn_attacks() -> Table {
  bit_board.iter_list(bit_board.new(), fn(sq, _) {
    let x = sq % 8

    case { sq - x } / 8 {
      0 -> [#(sq, [])]
      _ -> [
        #(sq, case x {
          0 -> [sq - 7]
          7 -> [sq - 9]
          _ -> [sq - 7, sq - 9]
        }),
      ]
    }
  })
  |> dict.from_list()
}

fn gen_knights() -> Table {
  bit_board.iter_list(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = { sq - x } / 8

    let rot = fn(l, xo, yo) {
      case x + xo >= 0 && x + xo < 8 && y + yo >= 0 && y + yo < 8 {
        True -> list.prepend(l, sq + xo + yo * 8)
        False -> l
      }
    }

    [
      #(
        sq,
        []
          //Top left clockwise
          |> rot(-1, 2)
          |> rot(1, 2)
          |> rot(2, 1)
          |> rot(2, -1)
          |> rot(1, -2)
          |> rot(-1, -2)
          |> rot(-2, -1)
          |> rot(-2, 1),
      ),
    ]
  })
  |> dict.from_list()
}

fn gen_kings() -> Table {
  bit_board.iter_list(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = { sq - x } / 8

    let rot = fn(l, xo, yo) {
      case x + xo >= 0 && x + xo < 8 && y + yo >= 0 && y + yo < 8 {
        True -> list.prepend(l, sq + xo + yo * 8)
        False -> l
      }
    }

    [
      #(
        sq,
        []
          //Top left clockwise
          |> rot(-1, 1)
          |> rot(-1, 0)
          |> rot(-1, -1)
          |> rot(1, 1)
          |> rot(1, 0)
          |> rot(1, -1)
          |> rot(0, -1)
          |> rot(0, 1),
      ),
    ]
  })
  |> dict.from_list()
}

fn gen_combi(size: Int) -> List(BitArray) {
  case size {
    0 -> []
    x -> {
      let prev = gen_combi(x - 1)

      let zer = list.map(prev, fn(x) { <<0:1, x:bits>> })
      let on = list.map(prev, fn(x) { <<1:1, x:bits>> })

      list.append(zer, on)
    }
  }
}

fn gen_rows() -> SlideTable {
  bit_board.iter_list(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = sq - x

    [
      #(
        sq,
        #(
          case x > 0 {
            True -> list.range(x - 1, 0) |> list.map(fn(p) { y + p })
            False -> []
          },
          case x < 7 {
            True -> list.range(x + 1, 7) |> list.map(fn(p) { y + p })
            False -> []
          },
        ),
      ),
    ]
  })
  |> dict.from_list()
}

fn gen_cols() -> SlideTable {
  bit_board.iter_list(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = sq - x

    [
      #(
        sq,
        #(
          case y / 8 > 0 {
            True -> list.range(y / 8 - 1, 0) |> list.map(fn(p) { p * 8 + x })
            False -> []
          },
          case y / 8 < 7 {
            True -> list.range(y / 8 + 1, 7) |> list.map(fn(p) { p * 8 + x })
            False -> []
          },
        ),
      ),
    ]
  })
  |> dict.from_list()
}

fn gen_diag() -> SlideTable {
  bit_board.iter_list(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = { sq - x } / 8

    let mini = int.min(x, y)
    let start = { x - mini } + { y - mini } * 8
    let size = 8 - int.max(x, y) + mini

    [
      #(
        sq,
        #(
          case mini > 0 {
            True -> list.range(mini - 1, 0) |> list.map(fn(p) { start + p * 9 })
            False -> []
          },
          case mini < size - 1 {
            True ->
              list.range(mini + 1, size - 1)
              |> list.map(fn(p) { start + p * 9 })
            False -> []
          },
        ),
      ),
    ]
  })
  |> dict.from_list()
}

fn gen_o_diag() -> SlideTable {
  bit_board.iter_list(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = { sq - x } / 8

    let mini = int.min(x, 7 - y)
    let start = { x - mini } + { y + mini } * 8
    let size = 8 - int.absolute_value(7 - x - y)

    [
      #(
        sq,
        #(
          case mini > 0 {
            True -> list.range(mini - 1, 0) |> list.map(fn(p) { start - p * 7 })
            False -> []
          },
          case mini < size - 1 {
            True ->
              list.range(mini + 1, size - 1)
              |> list.map(fn(p) { start - p * 7 })
            False -> []
          },
        ),
      ),
    ]
  })
  |> dict.from_list()
}

pub fn gen_tables() -> Tables {
  Tables(
    pawns: gen_pawn_attacks(),
    r_pawns: gen_r_pawn_attacks(),
    knights: gen_knights(),
    kings: gen_kings(),
    rows: gen_rows(),
    cols: gen_cols(),
    diags: gen_diag(),
    o_diags: gen_o_diag(),
  )
}

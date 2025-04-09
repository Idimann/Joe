import bit_board
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import square

pub type Table =
  dict.Dict(square.Square, List(square.Square))

pub type Tables {
  Tables(
    pawns: Table,
    pawn_attacks: Table,
    knights: Table,
    kings: Table,
    rows: Table,
    cols: Table,
    diag: Table,
    o_diag: Table,
  )
}

fn gen_pawns() -> Table {
  bit_board.iter(bit_board.new(), fn(sq, _) {
    let y = { sq - sq % 8 } / 8

    option.Some(
      #(sq, case y {
        7 -> []
        1 -> [sq + 8, sq + 16]
        _ -> [sq + 8]
      }),
    )
  })
  |> dict.from_list()
}

fn gen_pawn_attacks() -> Table {
  bit_board.iter(bit_board.new(), fn(sq, _) {
    let x = sq % 8

    option.Some(
      #(sq, case x {
        0 -> [sq + 9]
        7 -> [sq + 7]
        _ -> [sq + 9, sq + 7]
      }),
    )
  })
  |> dict.from_list()
}

fn gen_knights() -> Table {
  bit_board.iter(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = { sq - x } / 8

    let rot = fn(l, xo, yo) {
      case x + xo >= 0 && x + xo < 8 && y + yo >= 0 && y + yo < 8 {
        True -> list.prepend(l, sq + xo + yo * 8)
        False -> l
      }
    }

    option.Some(#(
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
    ))
  })
  |> dict.from_list()
}

fn gen_kings() -> Table {
  bit_board.iter(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = { sq - x } / 8

    let rot = fn(l, xo, yo) {
      case x + xo >= 0 && x + xo < 8 && y + yo >= 0 && y + yo < 8 {
        True -> list.prepend(l, sq + xo + yo * 8)
        False -> l
      }
    }

    option.Some(#(
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
    ))
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

///This function is so dumb
fn make_slide(pos: Int, line: BitArray, checking: Int) -> Int {
  case checking == pos {
    True -> 1
    False ->
      case line {
        <<_:size(checking)-bits, 1:1, _:bits>> -> 0
        _ ->
          make_slide(pos, line, case checking > pos {
            True -> checking - 1
            False -> checking + 1
          })
      }
  }
}

fn gen_rows() -> Table {
  bit_board.iter(bit_board.new(), fn(sq, _) {
    let y = sq - sq % 8

    option.Some(#(sq, list.range(0, 7) |> list.map(fn(p) { y + p })))
  })
  |> dict.from_list()
}

fn gen_cols() -> Table {
  bit_board.iter(bit_board.new(), fn(sq, _) {
    let x = sq % 8

    option.Some(#(sq, list.range(0, 7) |> list.map(fn(p) { p * 8 + x })))
  })
  |> dict.from_list()
}

fn gen_diag() -> Table {
  bit_board.iter(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = { sq - x } / 8

    let mini = int.min(x, y)
    let start = { x - mini } + { y - mini } * 8
    let size = 8 - int.max(x, y) + mini

    option.Some(#(
      sq,
      //9 is correct
      list.range(0, size - 1) |> list.map(fn(p) { start + p * 9 }),
    ))
  })
  |> dict.from_list()
}

///This is bugged
fn gen_o_diag() -> Table {
  bit_board.iter(bit_board.new(), fn(sq, _) {
    let x = sq % 8
    let y = { sq - x } / 8

    let mini = int.min(x, y)
    let start = { x - mini } + { y - mini } * 8
    let size = 8 - int.max(x, y) + mini

    option.Some(#(
      sq,
      //9 is correct
      list.range(0, size - 1) |> list.map(fn(p) { start + p * 9 }),
    ))
  })
  |> dict.from_list()
}

pub fn gen_tables() -> Tables {
  Tables(
    pawns: gen_pawns(),
    pawn_attacks: gen_pawn_attacks(),
    knights: gen_knights(),
    kings: gen_kings(),
    rows: gen_rows(),
    cols: gen_cols(),
    diag: gen_diag(),
    o_diag: gen_o_diag(),
  )
}

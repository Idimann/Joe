import bit_board
import gleam/dict
import gleam/option
import gleam/list
import square

pub type Table =
  dict.Dict(square.Square, List(square.Square))

//All of these are 8 bits
pub type SlideTable =
  dict.Dict(#(BitArray, BitArray), BitArray)

pub type Tables {
  Tables(
    pawns: Table,
    pawn_attacks: Table,
    knights: Table,
    kings: Table,
    sliding: SlideTable,
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
//
// fn gen_combi(size: Int) -> List(BitArray) {
//   case size {
//     0 -> []
//     x -> {
//       let prev = gen_combi(x - 1)
//
//       let zer = list.map(prev, fn(x) { <<0:1, x:bits>> })
//       let on = list.map(prev, fn(x) { <<1:1, x:bits>> })
//
//       list.append(zer, on)
//     }
//   }
// }
//
// ///This function is so dumb
// fn make_slide(pos: Int, line: BitArray, checking: Int) -> Int {
//   case checking == pos {
//     True -> 1
//     False ->
//       case line {
//         <<_:size(checking)-bits, 1:1, _:bits>> -> 0
//         _ ->
//           make_slide(pos, line, case checking > pos {
//             True -> checking - 1
//             False -> checking + 1
//           })
//       }
//   }
// }
//
// ///First one is our piece, second one are others
// fn gen_sliding() -> SlideTable {
//   bit_line.each_array(8, fn(line) {
//     bit_line.each_bit(8, fn(arr, pos) {
//       #(#(arr, line), <<
//         make_slide(pos, line, 0):1,
//         make_slide(pos, line, 1):1,
//         make_slide(pos, line, 2):1,
//         make_slide(pos, line, 3):1,
//         make_slide(pos, line, 4):1,
//         make_slide(pos, line, 5):1,
//         make_slide(pos, line, 6):1,
//         make_slide(pos, line, 7):1,
//       >>)
//     })
//   })
//   |> list.flatten()
//   |> dict.from_list()
// }
//
pub fn gen_tables() -> Tables {
  Tables(
    pawns: gen_pawns(),
    pawn_attacks: gen_pawn_attacks(),
    knights: gen_knights(),
    kings: gen_kings(),
    sliding: dict.new(), //gen_sliding(),
  )
}

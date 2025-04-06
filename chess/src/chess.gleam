import benchmark
import board
import gleam/io
import gleam/list
import gleam/option
import move
import movegen
import tablegen

//Don't continue using bit boards. They aren't the way gleam wants you to do it.
//Use a singular board instead. It is represented by a BitArray and uses
//4 bits for each square. (32 byte board). (More efficient than real bit boards).
//The first bit represents the color of whos on the square. The other 3 represent
//the piece type. 3 bits can represent at max 8 nums. There are 6 types of pieces.
//A square can also be empty or represent the en passant square. These are our other
//2 possibilities. This will be extremely efficient. All other board information can be
//stored in another BitArray call flags. These are values like 'white', 'mirrored'
//or 'mirrored_h'. They can then be extracted using pattern matching.
//All of this will make boards only 33 bytes overall and way more efficient for
//move generation as well.
//Tables should stay. Instead of using bit_boards, they just use squares/moves directly.
pub fn main() {
  let assert option.Some(b) =
    board.from_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
  b |> board.pretty_print() |> io.println()

  let tables = tablegen.gen_tables()

  benchmark.repeat(10000, fn() {
    movegen.gen(b, tables)
  })
  echo list.map(movegen.gen(b, tables), fn(x) { move.to_string(x, !b.white) })
}

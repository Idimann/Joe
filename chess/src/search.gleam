import board
import eval
import gleam/float
import gleam/int
import gleam/list
import gleam/order
import gleam/otp/task
import move
import movegen
import prng/random
import tablegen

pub type GameEnd {
  Win
  Draw
  Loss
}

pub fn mcts_val(n: Float, pn: Float, w: Float, e: Float) -> Float {
  case n {
    //TODO: Make this an actual value
    0.0 -> 420.0
    _ -> {
      let assert Ok(log) = float.logarithm(pn)
      let assert Ok(sqrt) = float.square_root(log /. n)

      { w +. e } /. n +. sqrt
    }
  }
}

fn mcts_do(
  b: board.Board,
  prev: List(board.Board),
  t: tablegen.Tables,
  side: Bool,
  len: Int,
) -> #(GameEnd, Int) {
  let ms = movegen.gen(b, t)

  case list.contains(prev, b) {
    True -> #(Draw, len + 1)
    False ->
      case ms {
        #([], v) ->
          case v {
            True ->
              case b.white == side {
                True -> #(Loss, len + 1)
                False -> #(Win, len + 1)
              }
            False -> #(Draw, len + 1)
          }
        #([head, ..tail], _) -> {
          let gen = random.uniform(head, tail)
          let pos = random.random_sample(gen)
          mcts_do(pos.1, [b, ..prev], t, side, len + 1)
        }
      }
  }
}

pub fn mcts(
  b: board.Board,
  t: tablegen.Tables,
  n: Int,
) -> #(Float, move.Move, board.Board) {
  let assert Ok(ret) =
    movegen.gen(b, t).0
    |> list.map(fn(pos) {
      #(
        task.async(fn() {
          let ss =
            list.range(1, n)
            |> list.map(fn(_) {
              case mcts_do(pos.1, [b], t, b.white, 0).0 {
                Win -> max_val
                Draw -> 0.0
                Loss -> 0.0 -. max_val
              }
            })

          let assert Ok(acc) = list.reduce(ss, fn(acc, x) { acc +. x })
          acc /. int.to_float(list.length(ss))
        }),
        pos.0,
        pos.1,
      )
    })
    |> list.map(fn(x) { #(task.await_forever(x.0), x.1, x.2) })
    |> list.max(fn(x, y) { float.compare(x.0, y.0) })

  #({ ret.0 +. max_val } /. { 2.0 *. max_val }, ret.1, ret.2)
}

fn max_break(
  ls: List(a),
  cur: Float,
  cut: Float,
  func: fn(a, Float) -> Float,
  order: order.Order,
) -> Float {
  case ls {
    [] -> cur
    [head, ..tail] -> {
      let val = func(head, cur)
      case float.compare(val, cut) {
        order.Eq -> {
          case float.compare(val, cur) == order {
            True -> val
            False -> cur
          }
        }
        od ->
          case od == order {
            True -> cur
            False ->
              case float.compare(val, cur) == order {
                True -> max_break(tail, val, cut, func, order)
                False -> max_break(tail, cur, cut, func, order)
              }
          }
      }
    }
  }
}

fn alpha_beta_do(
  b: board.Board,
  prev: List(board.Board),
  t: tablegen.Tables,
  side: Bool,
  depth: Int,
  alpha: Float,
  beta: Float,
) -> Float {
  case depth {
    0 -> eval.simple_eval(b, side)
    _ -> {
      let ms = movegen.gen(b, t)

      case list.contains(prev, b) {
        True -> 0.5
        False ->
          case ms {
            #([], v) ->
              case v {
                True ->
                  case b.white == side {
                    True -> 0.0 -. max_val
                    False -> max_val
                  }
                False -> 0.0
              }
            #(ls, _) ->
              case b.white == side {
                True ->
                  max_break(
                    ls,
                    alpha,
                    beta,
                    fn(x, al) {
                      alpha_beta_do(
                        x.1,
                        [b, ..prev],
                        t,
                        side,
                        depth - 1,
                        al,
                        beta,
                      )
                    },
                    order.Gt,
                  )
                False ->
                  max_break(
                    ls,
                    beta,
                    alpha,
                    fn(x, bet) {
                      alpha_beta_do(
                        x.1,
                        [b, ..prev],
                        t,
                        side,
                        depth - 1,
                        alpha,
                        bet,
                      )
                    },
                    order.Lt,
                  )
              }
          }
      }
    }
  }
}

const max_val: Float = 100000.0

pub fn alpha_beta(
  b: board.Board,
  t: tablegen.Tables,
  n: Int,
) -> #(Float, move.Move, board.Board) {
  let assert Ok(ret) =
    movegen.gen(b, t).0
    |> list.map(fn(pos) {
      #(
        task.async(fn() {
          let ss =
            list.range(1, n)
            |> list.map(fn(_) {
              alpha_beta_do(pos.1, [b], t, b.white, n, 0.0 -. max_val, max_val)
            })

          let assert Ok(acc) = list.reduce(ss, fn(acc, x) { acc +. x })
          acc /. int.to_float(list.length(ss))
        }),
        pos.0,
        pos.1,
      )
    })
    |> list.map(fn(x) { #(task.await_forever(x.0), x.1, x.2) })
    |> list.max(fn(x, y) { float.compare(x.0, y.0) })

  #({ ret.0 +. max_val } /. { 2.0 *. max_val }, ret.1, ret.2)
}

app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    aoc: "https://github.com/lukewilliamboswell/aoc-template/releases/download/0.2.0/tlS1ZkwSKSB87_3poSOXcwHyySe0WxWOWQbPmp7rxBw.tar.br",
}

import pf.Stdin
import pf.Stdout
import pf.Utc
import aoc.AoC {
    stdin: Stdin.readToEnd,
    stdout: Stdout.write,
    time: \{} -> Utc.now {} |> Task.map Utc.toMillisSinceEpoch,
}

main =
    AoC.solve {
        year: 2024,
        day: 3,
        title: "Historian Hysteria",
        part1,
        part2,
    }

unwrap : Result ok err, Str -> ok
unwrap = \result, crashMsg ->
    when result is
        Ok value -> value
        Err _ -> crash crashMsg

clear = \state -> { state & mode: Nothing, first_operand: [], second_operand: [] }

list_to_num : List U8 -> I32
list_to_num = \list ->
    list |> Str.fromUtf8 |> unwrap "couldn't convert from UTF8" |> Str.toI32 |> unwrap "couldn't convert to int"

parse : Str, Bool -> Result Str _
parse = \input, do_and_dont ->
    Str.walkUtf8
        input
        {
            enabled: Bool.true,
            mode: Nothing,
            first_operand: [],
            second_operand: [],
            result: 0,
        }
        \state, char ->
            { enabled, mode, first_operand, second_operand, result } = state
            when mode is
                Nothing ->
                    when char is
                        'm' if enabled -> { state & mode: M }
                        'd' if do_and_dont -> { state & mode: D }
                        _ -> clear state

                M ->
                    when char is
                        'u' -> { state & mode: U }
                        _ -> clear state

                U ->
                    when char is
                        'l' -> { state & mode: L }
                        _ -> clear state

                L ->
                    when char is
                        '(' -> { state & mode: OpenParen }
                        _ -> clear state

                OpenParen ->
                    when char is
                        '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '0' ->
                            { state &
                                mode: FirstOperand,
                                first_operand: List.append first_operand char,
                            }

                        _ -> clear state

                FirstOperand ->
                    when char is
                        '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '0' ->
                            { state &
                                first_operand: List.append first_operand char,
                            }

                        ',' -> { state & mode: Comma }
                        _ -> clear state

                Comma ->
                    when char is
                        '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '0' ->
                            { state &
                                mode: SecondOperand,
                                second_operand: List.append second_operand char,
                            }

                        _ -> clear state

                SecondOperand ->
                    when char is
                        '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '0' ->
                            { state &
                                second_operand: List.append second_operand char,
                            }

                        ')' ->
                            { state &
                                mode: Nothing,
                                first_operand: [],
                                second_operand: [],
                                result: result + ((list_to_num first_operand) * (list_to_num second_operand)),
                            }

                        _ -> clear state

                D ->
                    when char is
                        'o' -> { state & mode: O }
                        _ -> clear state

                O ->
                    when char is
                        '(' -> { state & mode: DoOpenParen }
                        'n' -> { state & mode: N }
                        _ -> clear state

                DoOpenParen ->
                    when char is
                        ')' -> { state & mode: Nothing, enabled: Bool.true, first_operand: [], second_operand: [] }
                        _ -> clear state

                N ->
                    when char is
                        '\'' -> { state & mode: Apostrophe }
                        _ -> clear state

                Apostrophe ->
                    when char is
                        't' -> { state & mode: T }
                        _ -> clear state

                T ->
                    when char is
                        '(' -> { state & mode: DontOpenParen }
                        _ -> clear state

                DontOpenParen ->
                    when char is
                        ')' -> { state & enabled: Bool.false, first_operand: [], second_operand: [], mode: Nothing }
                        _ -> clear state
    |> .result
    |> Num.toStr
    |> Ok

## Implement your part1 and part2 solutions here
part1 : Str -> Result Str []
part1 = \input -> parse input Bool.false

part2 : Str -> Result Str []
part2 = \input -> parse input Bool.true

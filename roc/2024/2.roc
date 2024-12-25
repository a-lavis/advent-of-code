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
        day: 2,
        title: "Red-Nosed Reports",
        part1,
        part2,
    }

## Implement your part1 and part2 solutions here
part1 : Str -> Result Str _
part1 = \input ->
    get_answer input is_report_safe

get_answer = \input, predicate ->
    reports = parse_reports? input
    bools = List.mapTry? reports predicate
    bools |> List.countIf (\bool -> bool) |> Num.toStr |> Ok

parse_reports : Str -> Result (List (List I32)) _
parse_reports = \input ->
    input
    |> Str.splitOn "\n"
    |> List.dropIf \line -> line == ""
    |> List.mapTry \line ->
        line
        |> Str.splitOn " "
        |> List.mapTry \num_str ->
            num_str |> Str.toI32

is_report_safe : List (Num *) -> Result Bool _
is_report_safe = \report ->
    first = List.first? report
    second = List.get? report 1

    direction = if first < second then Increasing else Decreasing
    List.walkFromUntil report 1 { previous: first, safe: Bool.true } \state, num ->
        difference =
            when direction is
                Increasing -> num - state.previous
                Decreasing -> state.previous - num
        if 1 <= difference && difference <= 3 then
            Continue { previous: num, safe: Bool.true }
        else
            Break { previous: num, safe: Bool.false }
    |> .safe
    |> Ok

is_report_safe_with_problem_dampener : List (Num *) -> Result Bool _
is_report_safe_with_problem_dampener = \report ->
    if is_report_safe? report then
        Ok Bool.true
    else
        List.range { start: At 0, end: Before (List.len report) }
        |> List.any \index ->
            report |> List.dropAt index |> is_report_safe |> unwrap
        |> Ok

unwrap : Result ok err -> ok
unwrap = \result ->
    when result is
        Ok value -> value
        Err _ -> crash "expected Ok"

part2 : Str -> Result Str _
part2 = \input ->
    get_answer input is_report_safe_with_problem_dampener

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
        day: 1,
        title: "Historian Hysteria",
        part1,
        part2,
    }

## Part 1: Total Distance
part1 : Str -> Result Str _
part1 = \input ->
    (col_a, col_b) = parse_input? input
    distances = List.map2 col_a col_b \num_a, num_b ->
        Num.absDiff num_a num_b
    distance_sum = List.sum distances
    Ok (Num.toStr distance_sum)

parse_input : Str -> Result (List I32, List I32) _
parse_input = \input ->
    lines = Str.splitOn input "\n" |> List.dropIf \line -> line == ""
    number_pairs : List (I32, I32)
    number_pairs = List.mapTry? lines \line ->
        split_line = Str.splitOn line " "
        results = List.mapTry? [List.first? split_line, List.last? split_line] \result ->
            Ok (Str.toI32? result)
        Ok (List.first? results, List.last? results)
    (resulting_col_a, resulting_col_b) = List.walk number_pairs ([], []) \cols, number_pair ->
        (col_a, col_b) = cols
        (num_a, num_b) = number_pair
        (List.append col_a num_a, List.append col_b num_b)
    Ok (List.sortAsc resulting_col_a, List.sortAsc resulting_col_b)

part2 : Str -> Result Str _
part2 = \input ->
    (col_a, col_b) = parse_input? input
    scores = List.map col_a \num_a ->
        num_a * Num.intCast (List.countIf col_b (\num_b -> num_b == num_a))
    score_sum = List.sum scores
    Ok (Num.toStr score_sum)

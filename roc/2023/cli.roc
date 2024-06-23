app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.10.0/vNe6s9hWzoTZtFmNkvEICPErI9ptji_ySjicO6CkucY.tar.br",
    weaver: "https://github.com/smores56/weaver/releases/download/0.2.0/BBDPvzgGrYp-AhIDw0qmwxT0pWZIQP_7KOrUrZfp_xw.tar.br",
}

import pf.Path
import pf.File
import pf.Stdout
import pf.Arg
import pf.Task exposing [Task]
import weaver.Cli
import weaver.Param
import weaver.Opt

cliParser =
    Cli.weave {
        isInput: <- Opt.flag { short: "i", help: "Run on the input instead of the example" },
        year: <- Param.u16 { name: "year", help: "What Advent-of-Code year to run" },
        day: <- Param.u8 { name: "day", help: "What Advent-of-Code day to run" },
        suffix: <- Param.maybeStr { name: "suffix", help: "Suffix of the file (input or example)" },
    }
    |> Cli.finish {
        name: "aoc",
    }
    |> Cli.assertValid

main =
    args = Arg.list!

    when Cli.parseOrDisplayMessage cliParser args is
        Ok data ->
            fileInputType =
                if data.isInput then
                    "input"
                else
                    "example"
            # suffix = ""
            suffix =
                when data.suffix is
                    Ok str -> "-$(str)"
                    Err NoValue -> ""

            filename = "../../$(fileInputType)s/$(Num.toStr data.year)/$(Num.toStr data.day)$(suffix).txt"

            content = File.readUtf8! (Path.fromStr filename)

            function =
                when data.day is
                    1 -> dayOne
                    _ -> \_ -> Stdout.line! "Can't do this lol"

            function content

        Err message ->
            Stdout.line! message

            Task.err (Exit 1 "")

dayOne = \content ->
    lines = List.dropIf (Str.split content "\n") Str.isEmpty
    sum = List.walk lines 0 \acc, line ->
        acc + getCalibrationValue line
    Stdout.line! (Num.toStr sum)

getCalibrationValueFromFirstAndLast = \first, last ->
    calibrationValueString =
        when Str.fromUtf8 [first, last] is
            Ok str -> str
            Err _ -> crash "Couldn't parse the number"
    when Str.toU64 calibrationValueString is
        Ok num -> num
        Err _ -> crash "Couldn't parse the number"

getCalibrationValue : Str -> U64
getCalibrationValue = \line ->
    intList = Str.toUtf8 line
    first =
        when getFirstDigit intList is
            Ok digit -> digit
            Err _ -> crash "No first digit found"
    last =
        when getLastDigit intList is
            Ok digit -> digit
            Err _ -> crash "No last digit found"
    getCalibrationValueFromFirstAndLast first last

getFirstDigit : List U8 -> Result U8 _
getFirstDigit = \intList ->
    getDigit intList List.first List.dropFirst List.append Str.endsWith

getLastDigit : List U8 -> Result U8 _
getLastDigit = \intList ->
    getDigit intList List.last List.dropLast List.prepend Str.startsWith

getDigit : List U8, (List U8 -> Result U8 _), (List U8, U64 -> List U8), (List U8, U8 -> List U8), (Str, Str -> Bool) -> Result U8 _
getDigit = \initialIntList, getFromListFunc, dropFromListFunc, concatFunc, findFunc ->
    getDigitAcc = \intList, acc ->
        accString <- Str.fromUtf8 acc |> Result.try
        if findFunc accString "one" then
            Ok '1'
        else if findFunc accString "two" then
            Ok '2'
        else if findFunc accString "three" then
            Ok '3'
        else if findFunc accString "four" then
            Ok '4'
        else if findFunc accString "five" then
            Ok '5'
        else if findFunc accString "six" then
            Ok '6'
        else if findFunc accString "seven" then
            Ok '7'
        else if findFunc accString "eight" then
            Ok '8'
        else if findFunc accString "nine" then
            Ok '9'
        else
            char <- getFromListFunc intList |> Result.try
            when char is
                '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' -> Ok char
                _ -> getDigitAcc (dropFromListFunc intList 1) (concatFunc acc char)
    getDigitAcc initialIntList []

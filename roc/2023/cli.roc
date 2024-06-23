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

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

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
                    2 -> dayTwo
                    _ -> \_ -> Stdout.line! "Can't do this lol"

            function content

        Err message ->
            Stdout.line! message

            Task.err (Exit 1 "")

# ----------------------------------------------------------------------------
# Day One
# ----------------------------------------------------------------------------

dayOne : Str -> Task {} _
dayOne = \content ->
    lines = List.dropIf (Str.split content "\n") Str.isEmpty
    sum = List.walk lines 0 \acc, line ->
        when getCalibrationValue line is
            Ok value -> acc + value
            Err _ -> crash "Couldn't get the calibration value"
    Stdout.line! (Num.toStr sum)

getCalibrationValue : Str -> Result U64 _
getCalibrationValue = \line ->
    intList = Str.toUtf8 line
    first <- getFirstDigit intList |> Result.try
    last <- getLastDigit intList |> Result.try
    getCalibrationValueFromFirstAndLast first last

getCalibrationValueFromFirstAndLast = \first, last ->
    calibrationValueString <- Str.fromUtf8 [first, last] |> Result.try
    Str.toU64 calibrationValueString

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

# ----------------------------------------------------------------------------
# Day Two
# ----------------------------------------------------------------------------

dayTwo : Str -> Task {} _
dayTwo = \content ->
    lines = List.dropIf (Str.split content "\n") Str.isEmpty
    games =
        when List.mapTry lines createGame is
            Ok list -> list
            Err _ -> crash "Couldn't create the games"
    Stdout.line! "Part One: $(Num.toStr (dayTwoPartOne games))"
    partTwo =
        when dayTwoPartTwo games is
            Ok value -> value
            Err _ -> crash "Couldn't get the part two value"
    Stdout.line! "Part Two: $(Num.toStr partTwo)"

Round : { redCount : I64, greenCount : I64, blueCount : I64 }
Game : { id : I64, rounds : List Round }

createGame : Str -> Result Game _
createGame = \line ->
    result <- Str.splitFirst line ":" |> Result.try
    gameString = result.before
    roundsString = result.after
    id <- getGameId gameString |> Result.try
    rounds <- getRounds roundsString |> Result.try
    Ok { id, rounds }

getGameId : Str -> Result I64 _
getGameId = \gameString ->
    result <- Str.splitFirst gameString " " |> Result.try
    Str.toI64 result.after

getRounds : Str -> Result (List Round) _
getRounds = \roundsString ->
    roundStrings = Str.split roundsString ";"
    List.mapTry roundStrings createRound

createRound : Str -> Result Round _
createRound = \roundString ->
    List.walk (Str.split roundString ",") (Ok { redCount: 0, greenCount: 0, blueCount: 0 }) \accResult, colorString ->
        acc <- accResult |> Result.try
        result <- Str.splitFirst (Str.trim colorString) " " |> Result.try
        color = result.after
        count <- Str.toI64 result.before |> Result.try
        when color is
            "red" -> Ok { acc & redCount: acc.redCount + count }
            "green" -> Ok { acc & greenCount: acc.greenCount + count }
            "blue" -> Ok { acc & blueCount: acc.blueCount + count }
            _ -> Err (InvalidColorErr "Invalid color found: $(color)")

dayTwoPartOne : List Game -> I64
dayTwoPartOne = \games ->
    games
    |> List.keepIf isGamePossible
    |> List.map .id
    |> List.sum

isGamePossible : Game -> Bool
isGamePossible = \game ->
    List.all game.rounds isRoundPossible

isRoundPossible : Round -> Bool
isRoundPossible = \round ->
    (round.redCount <= 12) && (round.greenCount <= 13) && (round.blueCount <= 14)

dayTwoPartTwo : List Game -> Result I64 _
dayTwoPartTwo = \games ->
    powers <- List.mapTry games powerOfMinmumSet |> Result.try
    Ok (List.sum powers)

powerOfMinmumSet : Game -> Result I64 _
powerOfMinmumSet = \game ->
    greatestRed <- getGreatestColorCount game .redCount |> Result.try
    greatestGreen <- getGreatestColorCount game .greenCount |> Result.try
    greatestBlue <- getGreatestColorCount game .blueCount |> Result.try

    Ok (greatestRed * greatestGreen * greatestBlue)

getGreatestColorCount : Game, (Round -> I64) -> Result I64 _
getGreatestColorCount = \game, getColorCountFunc ->
    game.rounds |> List.map getColorCountFunc |> List.max

# ----------------------------------------------------------------------------
# Day Three
# ----------------------------------------------------------------------------

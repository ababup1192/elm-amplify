module Tests exposing (updateTest, viewTest)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (..)
import Test exposing (..)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (containing, tag, text)


continuousIncrementDecrement : Msg -> Model -> Int -> Model
continuousIncrementDecrement msg currentCounter num =
    let
        nextCounter =
            update msg currentCounter |> Tuple.first
    in
    if num == 0 then
        currentCounter

    else
        continuousIncrementDecrement msg nextCounter (num - 1)


updateTest : Test
updateTest =
    describe "updateのテスト" <|
        [ describe "増えるカウンタ"
            [ test "カウンタが0のときIncrementされると1になる" <|
                \() ->
                    update Increment 0
                        |> Tuple.first
                        |> Expect.equal 1
            , test "カウンタが5のときIncrementされると6になる" <|
                \() ->
                    update Increment 5
                        |> Tuple.first
                        |> Expect.equal 6
            , test "カウンタが0のとき、5回Incrementされると5になる" <|
                \() ->
                    continuousIncrementDecrement Increment 0 5
                        |> Expect.equal 5
            ]
        , describe "減るカウンタ"
            [ test "カウンタが0のとDecrementされると-1になる" <|
                \() ->
                    update Decrement 0
                        |> Tuple.first
                        |> Expect.equal -1
            , test "カウンタが5のとDecrementされると4になる" <|
                \() ->
                    update Decrement 5
                        |> Tuple.first
                        |> Expect.equal 4
            ]
        ]


viewTest : Test
viewTest =
    describe "viewのテスト" <|
        [ describe "カウンタの表示"
            [ test "カウンタは0を表示している" <|
                \() ->
                    view 0
                        |> Query.fromHtml
                        |> Query.find [ tag "p" ]
                        |> Query.has [ text "0" ]
            , test "カウンタは15を表示している" <|
                \() ->
                    view 15
                        |> Query.fromHtml
                        |> Query.find [ tag "p" ]
                        |> Query.has [ text "15" ]
            ]
        , describe "増減ボタン"
            [ test "+ボタンはIncrement Msgを発行する" <|
                \() ->
                    view 0
                        |> Query.fromHtml
                        |> Query.find [ tag "button", containing [ text "+" ] ]
                        |> Event.simulate Event.click
                        |> Event.expect Increment
            , test "-ボタンはDecrement Msgを発行する" <|
                \() ->
                    view 0
                        |> Query.fromHtml
                        |> Query.find [ tag "button", containing [ text "-" ] ]
                        |> Event.simulate Event.click
                        |> Event.expect Decrement
            ]
        ]

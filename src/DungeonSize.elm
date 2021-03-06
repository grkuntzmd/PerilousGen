module DungeonSize exposing (DungeonSizeModel, DungeonSizeRow, dungeonSize, dungeonSizeView, select)

import DungeonMsg exposing (Msg(..))
import DungeonTheme exposing (DungeonThemeTracker, dungeonThemeView)
import Html exposing (Html, a, button, div, li, span, text, ul)
import Html.Attributes exposing (attribute, class, classList, href, type_)
import Html.Events exposing (onClick)
import Icons exposing (dice)
import List.Extra as List
import Maybe.Extra as Maybe
import Tables exposing (GenRandomMsg, SelectMsg, TableType(..))


type alias DungeonSizeModel m =
    { m
        | size : Maybe String
        , themes : List DungeonThemeTracker
        , countdowns : Int
        , areas : List (Maybe String)
    }


type alias DungeonSizeRow =
    { offset : Int
    , name : String
    , themeCount : Int
    , themeDie : Int
    , themeDieMod : Int
    , areaCount : Int
    , areaDieCount : Int
    , areaDieMod : Int
    }


dungeonSize : List DungeonSizeRow
dungeonSize =
    [ { offset = 3
      , name = "small"
      , themeCount = 2
      , themeDie = 4
      , themeDieMod = 0
      , areaCount = 6
      , areaDieCount = 1
      , areaDieMod = 2
      }
    , { offset = 9
      , name = "medium"
      , themeCount = 3
      , themeDie = 6
      , themeDieMod = 0
      , areaCount = 12
      , areaDieCount = 2
      , areaDieMod = 4
      }
    , { offset = 11
      , name = "large"
      , themeCount = 4
      , themeDie = 6
      , themeDieMod = 1
      , areaCount = 16
      , areaDieCount = 3
      , areaDieMod = 6
      }
    , { offset = 12
      , name = "huge"
      , themeCount = 5
      , themeDie = 6
      , themeDieMod = 2
      , areaCount = 24
      , areaDieCount = 4
      , areaDieMod = 10
      }
    ]


dungeonSizeView :
    DungeonSizeModel m
    -> SelectMsg Msg
    -> GenRandomMsg Msg
    -> List (Html Msg)
dungeonSizeView model selectMsg genMsg =
    let
        items =
            List.map
                (\{ name } ->
                    li
                        [ classList [ ( "uk-active", Maybe.unwrap False ((==) name) model.size ) ] ]
                        [ a
                            [ href "/perilousgen#dungeon"
                            , onClick (selectMsg DungeonSize name)
                            ]
                            [ text name ]
                        ]
                )
                dungeonSize

        name_ =
            Maybe.withDefault "none" model.size

        defaults =
            List.find (\{ name } -> Just name == model.size) dungeonSize
                |> Maybe.map
                    (\{ themeCount, themeDie, themeDieMod, areaCount, areaDieCount, areaDieMod } ->
                        { themeCount = themeCount
                        , themeDie = themeDie
                        , themeDieMod = themeDieMod
                        , areaCount = areaCount
                        , areaDieCount = areaDieCount
                        , areaDieMod = areaDieMod
                        }
                    )
                |> Maybe.withDefault
                    { themeCount = 0
                    , themeDie = 0
                    , themeDieMod = 0
                    , areaCount = 0
                    , areaDieCount = 0
                    , areaDieMod = 0
                    }

        themesStart =
            1 + defaults.themeDieMod

        themesEnd =
            defaults.themeDie + defaults.themeDieMod

        counts msg =
            List.range themesStart themesEnd
                |> List.map
                    (\i ->
                        li
                            [ classList [ ( "uk-active", i == defaults.themeCount ) ] ]
                            [ a
                                [ href "/perilousgen#dungeon"
                                , onClick (msg i)
                                ]
                                [ text (String.fromInt i) ]
                            ]
                    )

        themeCounts =
            counts SelectThemesMsg

        countdownCounts =
            counts SelectCountdownsMsg

        areasStart =
            1 + defaults.areaDieMod

        areasEnd =
            defaults.areaDieCount * 6 + defaults.areaDieMod

        areaCounts =
            List.range areasStart areasEnd
                |> List.map
                    (\i ->
                        li
                            [ classList [ ( "uk-active", i == defaults.areaCount ) ] ]
                            [ a
                                [ href "/perilousgen#dungeon"
                                , onClick (SelectAreasMsg i)
                                ]
                                [ text (String.fromInt i) ]
                            ]
                    )

        themes =
            List.indexedMap dungeonThemeView model.themes |> List.concat
    in
    [ li []
        [ div [ class "uk-inline" ]
            [ span [ onClick (genMsg DungeonSize) ] [ Icons.dice ]
            , button
                [ class "uk-button uk-button-default uk-margin-small-left uk-button-text", type_ "button" ]
                [ text "Size" ]
            , div
                [ attribute "uk-dropdown" "mode: click", class "uk-dropdown" ]
                [ ul [ class "uk-nav uk-dropdown-nav" ] items ]
            , span [ class "uk-label uk-margin-small-left" ] [ text name_ ]
            ]
        ]
    , li []
        [ div [ class "uk-inline" ]
            [ span [ onClick (GenThemesMsg themesStart themesEnd) ] [ Icons.dice ]
            , button
                [ class "uk-button uk-button-default uk-margin-small-left uk-button-text", type_ "button" ]
                [ text "Themes" ]
            , div
                [ attribute "uk-dropdown" "mode: click", class "uk-dropdown" ]
                [ ul [ class "uk-nav uk-dropdown-nav" ] themeCounts ]
            , span [ class "uk-label uk-margin-small-left" ] [ text (String.fromInt (List.length model.themes)) ]
            ]
        ]
    , li []
        [ div [ class "uk-inline" ]
            [ span [ onClick (GenCountdownsMsg themesStart themesEnd) ] [ Icons.dice ]
            , button
                [ class "uk-button uk-button-default uk-margin-small-left uk-button-text", type_ "button" ]
                [ text "Countdowns" ]
            , div
                [ attribute "uk-dropdown" "mode: click", class "uk-dropdown" ]
                [ ul [ class "uk-nav uk-dropdown-nav" ] countdownCounts ]
            , span [ class "uk-label uk-margin-small-left" ] [ text (String.fromInt model.countdowns) ]
            ]
        ]
    , li []
        [ div [ class "uk-inline" ]
            [ span [ onClick (GenAreasMsg areasStart areasEnd) ] [ Icons.dice ]
            , button
                [ class "uk-button uk-button-default uk-margin-small-left uk-button-text", type_ "button" ]
                [ text "Areas" ]
            , div
                [ attribute "uk-dropdown" "mode: click", class "uk-dropdown" ]
                [ ul [ class "uk-nav uk-dropdown-nav" ] areaCounts ]
            , span [ class "uk-label uk-margin-small-left" ] [ text (String.fromInt (List.length model.areas)) ]
            ]
        ]
    ]
        ++ themes


select : Int -> Maybe DungeonSizeRow
select offset_ =
    List.find (\{ offset } -> offset >= offset_) dungeonSize

module Model exposing (Model, State(..), initial, encode, decode)

import Json.Decode as Decode exposing (field)
import Json.Encode as Encode
import Grid exposing (Grid)
import Random
import Color exposing (Color)
import Time exposing (Time)


type State
    = Paused
    | Playing
    | Stopped


decodeState : String -> State
decodeState string =
    case string of
        "paused" ->
            Paused

        "playing" ->
            Playing

        _ ->
            Stopped


encodeState : State -> String
encodeState state =
    case state of
        Paused ->
            "paused"

        Playing ->
            "playing"

        Stopped ->
            "stopped"


type alias AnimationState =
    Maybe { active : Bool, elapsed : Time }


type alias Model =
    { active : Grid Color
    , position : ( Int, Float )
    , grid : Grid Color
    , lines : Int
    , next : Grid Color
    , score : Int
    , seed : Random.Seed
    , state : State
    , acceleration : Bool
    , moveLeft : Bool
    , moveRight : Bool
    , direction : AnimationState
    , rotation : AnimationState
    , width : Int
    , height : Int
    }


initial : Model
initial =
    { active = Grid.empty
    , position = ( 0, 0 )
    , grid = Grid.empty
    , lines = 0
    , next = Grid.empty
    , score = 0
    , seed = Random.initialSeed 0
    , state = Stopped
    , acceleration = False
    , moveLeft = False
    , moveRight = False
    , rotation = Nothing
    , direction = Nothing
    , width = 10
    , height = 20
    }


decodeColor : Decode.Decoder Color
decodeColor =
    Decode.map3 Color.rgb Decode.int Decode.int Decode.int


encodeColor : Color -> Encode.Value
encodeColor color =
    Color.toRgb color
        |> \{ red, green, blue } -> Encode.list (List.map Encode.int [ red, green, blue ])


decode : String -> Model -> Model
decode string model =
    { model
        | active = Result.withDefault model.active (Decode.decodeString (field "active" (Grid.decode decodeColor)) string)
        , position =
            ( Result.withDefault (Tuple.first model.position) (Decode.decodeString (field "positionX" Decode.int) string)
            , Result.withDefault (Tuple.second model.position) (Decode.decodeString (field "positionY" Decode.float) string)
            )
        , grid = Result.withDefault model.grid (Decode.decodeString (field "grid" (Grid.decode decodeColor)) string)
        , lines = Result.withDefault model.lines (Decode.decodeString (field "lines" (Decode.int)) string)
        , next = Result.withDefault model.next (Decode.decodeString (field "next" (Grid.decode decodeColor)) string)
        , score = Result.withDefault model.score (Decode.decodeString (field "score" (Decode.int)) string)
        , state = Result.withDefault model.state (Decode.decodeString (field "state" (Decode.map decodeState Decode.string)) string)
    }


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


encode : Int -> Model -> String
encode indent model =
    Encode.encode
        indent
        (Encode.object
            [ "active" => Grid.encode encodeColor model.active
            , "positionX" => Encode.int (Tuple.first model.position)
            , "positionY" => Encode.float (Tuple.second model.position)
            , "grid" => Grid.encode encodeColor model.grid
            , "lines" => Encode.int model.lines
            , "next" => Grid.encode encodeColor model.next
            , "score" => Encode.int model.score
            , "state" => Encode.string (encodeState model.state)
            ]
        )

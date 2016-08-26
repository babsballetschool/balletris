module Update exposing (update)
import Model exposing (..)
import Actions exposing (..)
import Tetriminos
import Time exposing (Time)
import Grid
import Random
import LocalStorage
import Task exposing (Task)


getFromStorage : Cmd Action
getFromStorage =
  LocalStorage.get "elm-flatris"
    |> Task.perform
       (always (Load ""))
       (\v -> Load (Maybe.withDefault "" v))


saveToStorage : Model -> (Model, Cmd Action)
saveToStorage model =
  LocalStorage.set "elm-flatris" (Model.encode 0 model)
    |> Task.perform (always Noop) (always Noop)
    |> (,) model


update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    Init ->
      let
        (next, seed) = Tetriminos.random (Random.initialSeed 0)
      in
        ( spawnTetrimino {model | seed = seed, next = next}
        , getFromStorage
        )
    Load string ->
      (Model.decode string model, Cmd.none)
    Start ->
      ( { model
        | state = Playing
        , lines = 0
        , score = 0
        , grid = Grid.empty
        }
      , Cmd.none
      )
    Pause ->
      saveToStorage {model | state = Paused}
    Resume ->
      ( {model | state = Playing}
      , Cmd.none
      )
    MoveLeft on ->
      ( startMove {model | moveLeft = on}
      , Cmd.none
      )
    MoveRight on ->
      ( startMove {model | moveRight = on}
      , Cmd.none
      )
    Rotate False ->
      ( {model | rotation = Nothing}
      , Cmd.none
      )
    Rotate True ->
      ( {model | rotation = Just {active = True, elapsed = 0}}
      , Cmd.none
      )
    Accelerate on ->
      ( {model | acceleration = on}
      , Cmd.none
      )
    UnlockButtons ->
      ( {model | rotation = Nothing, direction = Nothing, acceleration = False}
      , Cmd.none
      )
    Tick time ->
      model
        |> animate (min time 25)
        |> saveToStorage
    Noop ->
      (model, Cmd.none)


animate : Time -> Model -> Model
animate elapsed model =
  model
    |> moveTetrimino elapsed
    |> rotateTetrimino elapsed
    |> dropTetrimino elapsed
    |> checkEndGame


spawnTetrimino : Model -> Model
spawnTetrimino model =
  let
    (next, seed) = Tetriminos.random model.seed
    (x, y) = Grid.initPosition model.width model.next
  in
    { model
    | next = next
    , seed = seed
    , active = model.next
    , position = (x, toFloat y)
    }


direction : Model -> Int
direction {moveLeft, moveRight} =
  case (moveLeft, moveRight) of
    (True, False) -> -1
    (False, True) -> 1
    _ -> 0


startMove : Model -> Model
startMove model =
  if direction model /= 0 then
    {model | direction = Just {active = True, elapsed = 0}}
  else
    {model | direction = Nothing}


moveTetrimino : Time -> Model -> Model
moveTetrimino elapsed model =
  case model.direction of
    Just state ->
      {model | direction = Just (activateButton 150 elapsed state)}
      |> (if state.active then moveTetrimino' (direction model) else identity)
    Nothing -> model


moveTetrimino' : Int -> Model -> Model
moveTetrimino' dx model =
  let
    (x, y) = model.position
    x' = x + dx
  in
    if Grid.collide model.width model.height x' (floor y) model.active model.grid then
      model
    else
      {model | position = (x', y)}


activateButton : Time -> Time -> {a | active: Bool, elapsed: Time} -> {a | active: Bool, elapsed: Time}
activateButton interval elapsed state =
  let
    elapsed' = state.elapsed + elapsed
  in
    if elapsed' > interval then
      {state | active = True, elapsed = elapsed' - interval}
    else
      {state | active = False, elapsed = elapsed'}


rotateTetrimino : Time -> Model -> Model
rotateTetrimino elapsed model =
  case model.rotation of
    Just rotation ->
      {model | rotation = Just (activateButton 300 elapsed rotation)}
      |> (if rotation.active then rotateTetrimino' else identity)
    Nothing -> model


rotateTetrimino' : Model -> Model
rotateTetrimino' model =
  let
    (x, y) = model.position
    rotated = Grid.rotate True model.active
    shiftPosition deltas =
      case deltas of
        dx :: remainingDeltas ->
          if Grid.collide model.width model.height (x + dx) (floor y) rotated model.grid then
            shiftPosition remainingDeltas
          else
            { model
            | active = rotated
            , position = (x + dx, y)
            }
        [] ->
          model
  in
    shiftPosition [0, 1, -1, 2, -2]


checkEndGame : Model -> Model
checkEndGame model =
  if List.any identity (Grid.mapToList (\_ (_, y) -> y < 0) model.grid) then
    {model | state = Stopped}
  else
    model


dropTetrimino : Time -> Model -> Model
dropTetrimino elapsed model =
  let
    (x, y) = model.position
    speed =
      if model.acceleration then
        25
      else
        max 25 (800 - 25 * toFloat (level model - 1))
    y' = y + elapsed / speed
  in
    if Grid.collide model.width model.height x (floor y') model.active model.grid then
      let
        score = List.length (Grid.mapToList (\_ _ _ -> True) model.active)
      in
        { model
        | grid = Grid.stamp x (floor y) model.active model.grid
        , score = model.score + score * (if model.acceleration then 2 else 1)
        }
        |> spawnTetrimino
        |> clearLines
    else
      {model | position = (x, y')}


clearLines : Model -> Model
clearLines model =
  let
    (grid, lines) = Grid.clearLines model.width model.grid
    bonus = case lines of
      0 -> 0
      1 -> 100
      2 -> 300
      3 -> 500
      _ -> 800
  in
    { model
    | grid = grid
    , score = model.score + bonus * level model
    , lines = model.lines + lines
    }


level : Model -> Int
level model =
  model.lines // 10 + 1

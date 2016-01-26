module Saints.Note (Model, init, Action, update, view) where


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model =
  { id:   Int
  , memo: String
}
init: Model
init =
  { id   = 0
  , memo = ""
  }

type Action 
  = NoOp

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

view: Model -> Html
view model =
  li [] [text model.memo]

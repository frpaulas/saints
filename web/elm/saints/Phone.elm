module Saints.Phone (Model, init, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model =
  { id:      Int
  , ofType:  String
  , number:  String
  }
init: Model
init =
  { id      = 0
  , ofType  = ""
  , number  = ""
  }

type Action 
  = NoOp

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    
view: Model -> Html
view p =
  li [] [ text (p.ofType ++ ": " ++ p.number)]

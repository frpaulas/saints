module Saints.Address (Model, init, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model =
  { id:       Int
  , location: String
  , address1: String
  , address2: String
  , city:     String
  , state:    String
  , zip:      String
  , country:  String
  }
init: Model
init =
  { id = 0
  , location = ""
  , address1 = ""
  , address2 = ""
  , city =     ""
  , state =    ""
  , zip =      ""
  , country =  ""
  }

type Action 
  = NoOp

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

view: Model -> Html
view model =
  li [] 
    [ text model.location
    , p [] [ text model.address1 ]
    , p [] [ text model.address2 ]
    , p [] [ text (model.city ++ ", " ++ model.state ++ " " ++ model.zip) ]
    , p [] [ text model.country ]
    ]

module ElmSaints where

import Html exposing (..)
import Html.Attributes exposing (..)
import String exposing (join)
import StartApp
import Effects exposing (Effects, Never)
import Task exposing (Task)

app = 
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }

-- MODEL
type alias Donor =
  { id: Int
  , title: String
  , first_name: String
  , middle_name: String
  , last_name: String
  , name_ext: String
  }

type alias Model = 
  List Donor

init: (Model, Effects Action)
init = 
  let
    donors = 
      [ {title="The Rev.", first_name="Sam", last_name="Abbott", id=7008, middle_name="", name_ext=""}
      , {title="The Ven.", first_name="Jon", last_name="Abboud", id=7007, middle_name="", name_ext=""}
      , {title="", first_name="Steve", last_name="Abel", id=7006, middle_name="", name_ext=""}
      , {title="", first_name="Kim", last_name="Abner", id=7005, middle_name="", name_ext=""}
      , {title="", first_name="Rosemarie", last_name="Abrams", id=7004, middle_name="", name_ext=""}
      , {title="The Rev.", first_name="Joseph", last_name="Acanfora", id=7003, middle_name="", name_ext=""}
      , {title="", first_name="John & Betsy Acken,", last_name="Sr", id=7002, middle_name="", name_ext=""}
      , {title="The Rev.", first_name="Keith", last_name="Acker", id=7001, middle_name="", name_ext=""}
      , {title="The Rt. Rev.", first_name="Keith", last_name="Ackerman", id=7000, middle_name="", name_ext=""}
      , {title="The Rev.", first_name="Dennis", last_name="Ackerson", id=6999, middle_name="", name_ext=""}
      , {title="The Rev.", first_name="Josh", last_name="Acton", id=6998, middle_name="", name_ext=""}
      , {title="The Rev.", first_name="Josh", last_name="Acton", id=6997, middle_name="", name_ext=""}
      ]
  in
    (donors, Effects.none)

-- MAIN

main: Signal Html
main = 
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks


-- UPDATE
type Action 
  = NoOp

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  table [ class "table" ] [
    tbody [] (List.map (oneDonor address) model)
  ]

oneDonor: Signal.Address Action -> Donor -> Html
oneDonor address donor =
  tr [] [
    td [] [fullNameText donor]
  ]

fullNameText: Donor -> Html
fullNameText d =
  text (join " " [d.title, d.first_name, d.middle_name, d.last_name, d.name_ext, "(", toString d.id, ")"])
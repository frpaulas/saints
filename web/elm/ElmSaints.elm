module ElmSaints where

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (join)
import StartApp
import Effects exposing (Effects, Never)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import String
import Debug

app = 
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [incomingActions]
    }

-- MAIN

main: Signal Html
main = 
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks


-- MODEL

type alias Donor =
  { id: Int
  , title: String
  , firstName: String
  , middleName: String
  , lastName: String
  , nameExt: String
  }

type alias Model = 
  { totalPages: Int
  , totalEntries: Int
  , pageSize: Int
  , pageNumber: Int
  , donors: List Donor
  }

init: (Model, Effects Action)
init = 
  ( { totalPages = 0
    , totalEntries = 0
    , pageSize = 0
    , pageNumber = 0
    , donors = []
    } 
    , Effects.none
  )

-- UPDATE

type Action 
  = NoOp
  | SetDonors Model
  | First | Last | Prev | Next
  | UpdateFindDonor String

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> 
      let
        foo = Debug.log "UPDATE ACTION: " "NoOp"
      in
        (model, Effects.none)
    First -> 
      let
        foo = Debug.log "UPDATE ACTION: " "First"
      in
        (model, Effects.none)
    Last -> 
      let
        foo = Debug.log "UPDATE ACTION: " "Last"
      in
        (model, Effects.none)
    Prev -> 
      let
        foo = Debug.log "UPDATE ACTION: " "Prev"
      in
        (model, Effects.none)
    Next -> 
      let
        foo = Debug.log "UPDATE ACTION: " "Next"
      in
        (model, Effects.none)
    UpdateFindDonor name ->
      let
        foo = Debug.log "FIND THESE: " name
      in
        (model, Effects.none)
    SetDonors donors ->
      (donors, Effects.none)

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div [] 
    [ basicNav address model
    , donorTable address model 
    ]

basicNav: Signal.Address Action -> Model -> Html
basicNav address model =
  div []
    [ button [ onClick address Prev]  [ text "Prev"]
    , button [ onClick address First] [ text "First"]
    , button [ onClick address Last]  [ text "Last"]
    , button [ onClick address Next]  [ text "Next"]
    , findDonor address model
    ]

findDonor: Signal.Address Action -> Model -> Html
findDonor address model =
  input
    [ id "find-donor"
    , placeholder "Find by Last Name "
    , autofocus True
    , name "findDonor"
    , on "input" targetValue (Signal.message address << UpdateFindDonor)
    ]
    []

donorTable: Signal.Address Action -> Model -> Html
donorTable address model =
  table [ class "table" ] [
    tbody [] (List.map (oneDonor address) model.donors)
  ]

oneDonor: Signal.Address Action -> Donor -> Html
oneDonor address donor =
  tr [] [
    td [] [fullNameText donor]
  ]

fullNameText: Donor -> Html
fullNameText d =
  text (join " " [d.title, d.firstName, d.middleName, d.lastName, d.nameExt, "(", toString d.id, ")"])

-- SIGNALS

port donorLists: Signal Model

incomingActions: Signal Action
incomingActions =
  Signal.map SetDonors donorLists  
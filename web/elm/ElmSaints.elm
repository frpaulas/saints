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
import Mouse
import Graphics.Element exposing (..)

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

type alias Page =
  { totalPages: Int
  , totalEntries: Int
  , pageSize: Int
  , pageNumber: Int
  } 

type alias Model = 
  { page: Page
  , donors: List Donor
  }

initPage: Page
initPage = 
  { totalPages = 0
  , totalEntries = 0
  , pageSize = 0
  , pageNumber = 0
  } 


init: (Model, Effects Action)
init = 
  ( { page = initPage
    , donors = []
    } 
    , Effects.none
  )

type alias PageNo = Int
initPageNo: PageNo
initPageNo = 0

-- UPDATE

type Action 
  = NoOp
  | SetDonors Model
--  | First | Last | Prev | Next
--  | ChangePage Int
--  | UpdateFindDonor String

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> 
      let
        foo = Debug.log "UPDATE ACTION: " "NoOp"
      in
        (model, Effects.none)
    SetDonors donors ->
      (donors, Effects.none)
        -- (model, Effects.none)

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
    [ button [ onClick requestNewPage.address  (model.page.pageNumber - 1)]  [ text "Prev"]
    , button [ onClick requestNewPage.address  1] [ text "First"]
    , button [ onClick requestNewPage.address  model.page.totalPages]  [ text "Last"]
    , button [ onClick requestNewPage.address  (model.page.pageNumber + 1)]  [ text "Next"]
--    , findDonor address model
    ]

-- findDonor: Signal.Address Action -> Model -> Html
-- findDonor address model =
--   input
--     [ id "find-donor"
--     , placeholder "Find by Last Name "
--     , autofocus True
--     , name "findDonor"
--     , on "input" targetValue (Signal.message address << UpdateFindDonor)
--     ]
--     []

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

requestNewPage: Signal.Mailbox PageNo
requestNewPage =
  Signal.mailbox initPageNo

incomingActions: Signal Action
incomingActions =
  Signal.map SetDonors donorLists  

-- PORTS

port requestPage: Signal PageNo
port requestPage =
  requestNewPage.signal

port donorLists: Signal Model
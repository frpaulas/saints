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
  -- Signal.merge app.html nav.html
  app.html
  -- nav.html

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

type alias SearchName = String

type alias Page =
  { totalPages: Int
  , totalEntries: Int
  , pageSize: Int
  , pageNumber: Int
  } 

type alias Model = 
  { searchName: SearchName
  , page: Page
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
  ( { searchName = ""
    , page = initPage
    , donors = []
    } 
    , Effects.none
  )

-- UPDATE


type Action 
  = NoOp
  | SetDonors Model
  | UpdateFindDonor String

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> 
      (model, Effects.none)
    SetDonors donors ->
      (donors, Effects.none)
        -- (model, Effects.none)
    UpdateFindDonor name ->
      let
        thisPage = model.page
        newPage = {thisPage | pageNumber = 1}
        updatedModel = {model | page = newPage, searchName = name}
        foo = Debug.log "UPDATED MODEL" updatedModel
      in
        (updatedModel, Effects.none)

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div [ ] 
      [ basicNav address model
      , donorTable address model 
      ]

basicNav: Signal.Address Action -> Model -> Html
basicNav address model =
  div []
    [ button [ onClick nextPage.address ((model.page.pageNumber - 1), model.searchName)]  [ text "Prev"]
    , button [ onClick nextPage.address (1, model.searchName)] [ text "First"]
    , button [ onClick nextPage.address (model.page.totalPages, model.searchName)]  [ text "Last"]
    , button [ onClick nextPage.address ((model.page.pageNumber + 1), model.searchName)]  [ text "Next"]
    , findDonor address model
    , pageInfo address model
    ]

pageInfo: Signal.Address Action -> Model -> Html
pageInfo address model =
  table 
    [ class "page-info"]
    [ tbody [] 
      [ tr []
          [ th [] [ text "Finding"]
          , th [] [ text "Total Pages"]
          , th [] [ text "Total Entries"]
          , th [] [ text "Page Size"]
          , th [] [ text "Page No."]
          ]
      , tr []
          [ td [] [ text model.searchName]
          , td [] [ text (toString model.page.totalPages)]
          , td [] [ text (toString model.page.totalEntries)]
          , td [] [ text (toString model.page.pageSize)]
          , td [] [ text (toString model.page.pageNumber)]
          ]
      ]
    ]

findDonor: Signal.Address Action -> Model -> Html
findDonor address model =
  input
    [ id "find-donor"
    , type' "text"
    , placeholder "Find by Last Name, First "
    , autofocus True
    , name "findDonor"
    -- , on "input" targetValue (Signal.message address << UpdateFindDonor)
    , on "input" targetValue (\str -> Signal.message nextPage.address (1, str))
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

nextPage : Signal.Mailbox (Int, String)
nextPage =
  Signal.mailbox (0, "")

incomingActions: Signal Action
incomingActions =
  Signal.map SetDonors donorLists

-- PORTS

port donorLists: Signal Model
port requestPage: Signal (Int, String)
port requestPage = 
  nextPage.signal

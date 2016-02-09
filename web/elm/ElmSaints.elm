module ElmSaints where

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp
import Effects exposing (Effects, Never)
import Task exposing (Task)
import Json.Decode as Json exposing ((:=))
import Debug

import Saints.Address as Address
import Saints.Address exposing (addressUpdate)
import Saints.Note as Note
import Saints.Note exposing (noteUpdate)
import Saints.Phone as Phone
import Saints.Phone exposing (phoneUpdate)
import Saints.Donor exposing (donorUpdate, detailsGet)
import Saints.Donor as Donor

app = 
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [incomingActions, incomingDonor]
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

type alias SearchName = String
type alias ID = Int

type alias Page =
  { totalPages:   Int
  , totalEntries: Int
  , pageSize:     Int
  , pageNumber:   Int
  } 

type alias Model = 
  { searchName: SearchName
  , page:       Page
  , donors:     List Donor.Model
  }

type alias DBDonorList =
  { searchName: SearchName
  , page:       Page
  , donors:     List Donor.DBDonor
  }
initDBDonorList: DBDonorList
initDBDonorList =
  { searchName  = ""
  , page        = initPage
  , donors      = []
  }


initPage: Page
initPage = 
  { totalPages    = 0
  , totalEntries  = 0
  , pageSize      = 0
  , pageNumber    = 0
  } 


init: (Model, Effects Action)
init = 
  ( { searchName  = ""
    , page        = initPage
    , donors      = []
    } 
    , Effects.none
  )

hideDetails = True
showDetails = False

-- UPDATE


type Action 
  = NoOp
  | OKDonor Donor.DBDonor
  | SetDonors DBDonorList
  | Modify ID Donor.Action

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> 
      (model, Effects.none)
    OKDonor donor ->
      let 
        updateDonor donorModel =
          if donorModel.donor.id == donor.id 
            then Donor.makeModel showDetails donor 
            else donorModel
      in
        ({model | donors = List.map updateDonor model.donors}, Effects.none)
    SetDonors db ->
      let
        newModel = 
          { searchName = db.searchName
          , page = db.page
          , donors = List.map (Donor.makeModel hideDetails) db.donors
          }
      in
        -- (donors, Effects.none)
        (newModel, Effects.none)
    Modify id donorAction ->
      let
        updateDonor donorModel =
          if donorModel.donor.id == id
            then Donor.update donorAction donorModel
            else donorModel
      in
        ({model | donors = List.map updateDonor model.donors}, Effects.none)

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  let donors = List.map (viewDonors address) model.donors
  in
    div [ ] 
        [ basicNav address model
        , ul [] donors 
        ]

viewDonors: Signal.Address Action -> Donor.Model -> Html
viewDonors address model =
  Donor.view (Signal.forwardTo address (Modify model.donor.id)) model

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
    , on "input" targetValue (\str -> Signal.message nextPage.address (1, str))
    ]
    []

-- SIGNALS

nextPage : Signal.Mailbox (Int, String)
nextPage =
  Signal.mailbox (0, "")

incomingActions: Signal Action
incomingActions =
  Signal.map SetDonors donorLists

incomingDonor: Signal Action
incomingDonor =
  Signal.map OKDonor okDonor

donorOK: Signal.Mailbox Donor.Donor
donorOK =
  Signal.mailbox Donor.initDonor

-- PORTS

port requestPage: Signal (Int, String)
port requestPage = 
  nextPage.signal

port updateDonor: Signal Donor.Donor
port updateDonor = 
  donorUpdate.signal

port updateNote: Signal Note.Note
port updateNote = 
  noteUpdate.signal

port updateAddress: Signal Address.Address
port updateAddress =
  addressUpdate.signal

port updatePhone: Signal Phone.Phone
port updatePhone =
  phoneUpdate.signal

port requestDonorDetail: Signal Donor.Donor
port requestDonorDetail =
  detailsGet.signal


port donorLists: Signal DBDonorList
port okDonor: Signal Donor.DBDonor

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
import Saints.Address exposing (addressUpdate, addressDelete)
import Saints.Note as Note
import Saints.Note exposing (noteUpdate, noteDelete)
import Saints.Phone as Phone
import Saints.Phone exposing (phoneUpdate, phoneDelete)
import Saints.Donor exposing (donorUpdate, detailsGet, donorDelete)
import Saints.Donor as Donor
import Saints.Donation exposing (donationUpdate, donationDelete)
import Saints.Donation as Donation

app = 
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [incomingActions, incomingDonor, deletingDonor]
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
noDetails = False
gotDetails = True

-- UPDATE


type Action 
  = NoOp
  | OKDonor Donor.DBDonor
  | SetDonors DBDonorList
  | Modify ID Donor.Action
  | NewDonor
  | DeleteDonor Donor.Donor

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> 
      (model, Effects.none)

    OKDonor donor ->
      let 
        updateDonor donorModel =
          if donorModel.donor.id == donor.id 
            then Donor.makeModel showDetails gotDetails donor 
            else donorModel
      in
        ({model | donors = List.map updateDonor model.donors}, Effects.none)

    SetDonors db ->
      let
        newModel = 
          { searchName = db.searchName
          , page = db.page
          , donors = List.map (Donor.makeModel hideDetails noDetails) db.donors
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

    DeleteDonor donor ->
      let
        remainingDonors = List.filter (\d -> d.donor.id /= donor.id) model.donors
      in
        ({ model | donors = remainingDonors }, Effects.none)

    NewDonor -> 
      ({model | donors = [Donor.fromScratch] ++ model.donors}, Effects.none)

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
    [ button [ buttonStyle, onClick nextPage.address ((model.page.pageNumber - 1), model.searchName)]  [ text "Prev"]
    , button [ buttonStyle, onClick nextPage.address (1, model.searchName)] [ text "First"]
    , button [ buttonStyle, onClick nextPage.address (model.page.totalPages, model.searchName)]  [ text "Last"]
    , button [ buttonStyle, onClick nextPage.address ((model.page.pageNumber + 1), model.searchName)]  [ text "Next"]
    , button [ buttonStyle, onClick address NewDonor]  [ text "New Donor"]
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

deletingDonor: Signal Action
deletingDonor =
  Signal.map DeleteDonor donorDelete.signal

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

port deleteDonor: Signal Donor.Donor
port deleteDonor =
  donorDelete.signal

port updateDonation: Signal Donation.Donation
port updateDonation =
  donationUpdate.signal

port deleteDonation: Signal Donation.Donation
port deleteDonation =
  donationDelete.signal

port updateNote: Signal Note.Note
port updateNote = 
  noteUpdate.signal

port deleteNote: Signal Note.Note
port deleteNote =
  noteDelete.signal

port updateAddress: Signal Address.Address
port updateAddress =
  addressUpdate.signal

port deleteAddress: Signal Address.Address
port deleteAddress =
  addressDelete.signal

port updatePhone: Signal Phone.Phone
port updatePhone =
  phoneUpdate.signal

port deletePhone: Signal Phone.Phone
port deletePhone =
  phoneDelete.signal

port requestDonorDetail: Signal Donor.Donor
port requestDonorDetail =
  detailsGet.signal


port donorLists: Signal DBDonorList
port okDonor: Signal Donor.DBDonor


-- STYLE

buttonStyle: Attribute
buttonStyle =
  style
    [ ("margin", "0px 2px")
    ]
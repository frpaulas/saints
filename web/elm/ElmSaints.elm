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

type alias Address =
  { id:       Int
  , location: String
  , address1: String
  , address2: String
  , city:     String
  , state:    String
  , zip:      String
  , country:  String
  }
initAddress: Address
initAddress =
  { id = 0
  , location = ""
  , address1 = ""
  , address2 = ""
  , city =     ""
  , state =    ""
  , zip =      ""
  , country =  ""
  }

type alias Phone =
  { id:      Int
  , ofType:  String
  , number:  String
  }
initPhone: Phone
initPhone =
  { id      = 0
  , ofType  = ""
  , number  = ""
  }

type alias Note =
  { id:   Int
  , memo: String
}
initNote: Note
initNote =
  { id   = 0
  , memo = ""
  }


type alias Donor =
  { id:         Int
  , title:      String
  , firstName:  String
  , middleName: String
  , lastName:   String
  , nameExt:    String
  , phone:      List Phone
  , address:    List Address
  , note:       List Note
  , detailsCss: String 
  }
initDonor: Donor
initDonor =
  { id          = 0
  , title       = ""
  , firstName   = ""
  , middleName  = ""
  , lastName    = ""
  , nameExt     = ""
  , phone       = []
  , address     = []
  , note        = []
  , detailsCss  = "hide_details"
  }


type alias SearchName = String

type alias Page =
  { totalPages:   Int
  , totalEntries: Int
  , pageSize:     Int
  , pageNumber:   Int
  } 

type alias Model = 
  { searchName: SearchName
  , page:       Page
  , donors:     List Donor
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

-- UPDATE


type Action 
  = NoOp
  | SetDonors Model
  | ToggleDetails Donor

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> 
      (model, Effects.none)
    ToggleDetails donor ->
      let
        updateDonor d =
          if d.id /= donor.id then
            d
          else if d.detailsCss == "donor_details"
            then {d | detailsCss = "hide_details"}
          else
            {d | detailsCss = "donor_details"}
      in
        ({model | donors = List.map updateDonor model.donors}, Effects.none)
    SetDonors donors ->
      (donors, Effects.none)

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div [ ] 
      [ basicNav address model
      , donorList address model 
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
    , on "input" targetValue (\str -> Signal.message nextPage.address (1, str))
    ]
    []


donorList: Signal.Address Action -> Model -> Html
donorList address model =
  ul [ class "donor_list" ] (List.map (oneDonor address) model.donors)

oneDonor: Signal.Address Action -> Donor -> Html
oneDonor address donor =
  li 
    [ onClick address (ToggleDetails donor)] 
    [ fullNameText donor
    , donorDetailsFor address donor
    ]

donorDetailsFor: Signal.Address Action -> Donor -> Html
donorDetailsFor address donor =
  ul
    [ class donor.detailsCss]
    (List.concat [(donorNotes donor), (donorAddresses donor), (donorPhones donor)])

donorNotes: Donor -> List Html
donorNotes d = 
  List.map oneNote d.note

oneNote: Note -> Html
oneNote note =
  li [] [text note.memo]

donorAddresses: Donor -> List Html
donorAddresses d = 
  List.map oneAddress d.address

oneAddress: Address -> Html
oneAddress a =
  li [] 
    [ text a.location
    , p [] [ text a.address1 ]
    , p [] [ text a.address2 ]
    , p [] [ text (a.city ++ ", " ++ a.state ++ " " ++ a.zip) ]
    , p [] [ text a.country ]
    ]

donorPhones: Donor -> List Html
donorPhones d =
  List.map onePhone d.phone

onePhone: Phone -> Html
onePhone p =
  li [] [ text (p.ofType ++ ": " ++ p.number)]


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

donorDetail: Signal.Mailbox Int
donorDetail =
  Signal.mailbox 0

-- PORTS

port donorLists: Signal Model
port requestPage: Signal (Int, String)
port requestPage = 
  nextPage.signal
port requestDonorDetail: Signal Int
port requestDonorDetail =
  donorDetail.signal

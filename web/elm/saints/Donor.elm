module Saints.Donor (Model, init, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (join)


import Saints.Address as Address
import Saints.Note as Note
import Saints.Phone as Phone

type alias Model =
  { id:         Int
  , title:      String
  , firstName:  String
  , middleName: String
  , lastName:   String
  , nameExt:    String
  , phone:      List Phone.Model
  , address:    List Address.Model
  , note:       List Note.Model
  , detailsCss: String 
  }
init: Model
init =
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

-- UPDATE

type Action 
  = NoOp
  | ToggleDetails
  | Title String
  | FirstName String
  | MiddleName String
  | LastName String
  | NameExt String

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ToggleDetails ->
      let
        show_details = if model.detailsCss == "donor_details"
            then "hide_details"
            else "donor_details"
      in
        {model | detailsCss = show_details}
    Title       s -> { model | title = s }
    FirstName   s -> { model | firstName = s }
    MiddleName  s -> { model | middleName = s }
    LastName    s -> { model | lastName = s }
    NameExt     s -> { model | nameExt = s }

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  li 
    [] 
    [ span 
      [ onClick address ToggleDetails]
      [ fullNameText model ]
    , donorNameEdit address model
    , donorDetailsFor address model
    ]

donorNameEdit: Signal.Address Action -> Model -> Html
donorNameEdit address model =
  ul 
  [ class ("name_edit " ++ model.detailsCss)] 
  [ text "Edit Name" 
  , li 
    []
    [ inputTitle address model
    , inputFirstName address model
    , inputMiddleName address model
    , inputLastName address model
    , inputNameExt address model
    ]
  ]

inputTitle: Signal.Address Action -> Model -> Html
inputTitle address model =
  input 
    [ id "title"
    , type' "text"
    , placeholder "Title"
    , autofocus True
    , name "title"
    , on "input" targetValue (\str -> Signal.message address (Title str))
    , value model.title
    ]
    []

inputFirstName: Signal.Address Action -> Model -> Html
inputFirstName address model =
  input 
    [ id "first_name"
    , type' "text"
    , placeholder "First Name"
    , autofocus True
    , name "first_name"
    , on "input" targetValue (\str -> Signal.message address (FirstName str))
    , value model.firstName
    ]
    []

inputMiddleName: Signal.Address Action -> Model -> Html
inputMiddleName address model =
  input 
    [ id "middle_name"
    , type' "text"
    , placeholder "Middle Name"
    , autofocus True
    , name "middle_name"
    , on "input" targetValue (\str -> Signal.message address (MiddleName str))
    , value model.middleName
    ]
    []

inputLastName: Signal.Address Action -> Model -> Html
inputLastName address model =
  input 
    [ id "last_name"
    , type' "text"
    , placeholder "Last Name"
    , autofocus True
    , name "last_name"
    , on "input" targetValue (\str -> Signal.message address (LastName str))
    , value model.lastName
    ]
    []

inputNameExt: Signal.Address Action -> Model -> Html
inputNameExt address model =
  input 
    [ id "name_ext"
    , type' "text"
    , placeholder "Extension"
    , autofocus True
    , name "name_ext"
    , on "input" targetValue (\str -> Signal.message address (NameExt str))
    , value model.nameExt
    ]
    []

donorDetailsFor: Signal.Address Action -> Model -> Html
donorDetailsFor address model =
  ul
    [ class model.detailsCss]
    (    List.map Note.view model.note
      ++ List.map Address.view model.address
      ++ List.map Phone.view model.phone
    )


fullNameText: Model -> Html
fullNameText m =
  text (join " " [m.title, m.firstName, m.middleName, m.lastName, m.nameExt, "(", toString m.id, ")"])


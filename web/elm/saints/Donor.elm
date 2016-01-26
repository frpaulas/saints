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

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  li 
    [ onClick address ToggleDetails] 
    [ fullNameText model
    , donorDetailsFor address model
    ]

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


module Saints.Phone (Model, Phone, init, makeModel, phoneUpdate, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias ID = Int
type alias Phone =
  { id:      ID
  , ofType:  String
  , number:  String
  }
initPhone: Phone
initPhone =
  { id      = 0
  , ofType  = ""
  , number  = ""
  }
type alias Model =
  { phone: Phone
  , editing: Bool
  }
init: Model
init =
  { phone = initPhone
  , editing = False
  }

makeModel: Phone -> Model
makeModel phone =
  { phone = phone
  , editing = False
  }


-- SIGNALS

phoneUpdate: Signal.Mailbox Phone
phoneUpdate =
  Signal.mailbox initPhone


-- UPDATE

type Action 
  = NoOp
  | ToggleEditing
  | OfType String
  | Number String

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ToggleEditing -> {model | editing = not model.editing}
    OfType s -> 
      let
        phone = model.phone
        newPhone = {phone | ofType = s}
      in
        { model | phone = newPhone }
    Number s -> 
      let
        phone = model.phone
        newPhone = {phone | number = s}
      in
        { model | phone = newPhone}

-- VIEW
    
view: Signal.Address Action -> Model -> List Html
view address model =
  let phone = model.phone
  in
    [ li 
        [ onClick address ToggleEditing ] 
        [ text (phone.ofType ++ ": " ++ phone.number) ]
    , li
      []
      [ ul
        [ editingClass model ]
        [ li 
          [] 
          [ span [] [inputOfType address phone]
          , cancelSave address model
          ]
        , li [] [inputNumber address phone]
        ]
      ]
    ]

inputOfType: Signal.Address Action -> Phone -> Html
inputOfType address phone =
  p 
    []
    [ input 
      [ id "ofType"
      , type' "text"
      , placeholder "Type (phone, email, etc."
      , autofocus True
      , name "ofType"
      , on "input" targetValue (\str -> Signal.message address (OfType str))
      , value phone.ofType
      ]
      []
    ]

inputNumber: Signal.Address Action -> Phone -> Html
inputNumber address phone =
  p 
    []
    [ input 
      [ id "number"
      , type' "text"
      , placeholder "number or email"
      , autofocus True
      , name "number"
      , on "input" targetValue (\str -> Signal.message address (Number str))
      , value phone.number
      ]
      []
    ]

editingClass: Model -> Html.Attribute
editingClass model =
  class (if model.editing then "edit_details" else "hide")
viewingClass model =
  class (if model.editing then "hide" else "")
cancelSave: Signal.Address Action -> Model -> Html
cancelSave address model = 
  span 
    [ style [("float", "right"), ("margin-top", "-20px")] ]
    [ button [ onClick address ToggleEditing] [text "cancel"]
    , button [ onClick phoneUpdate.address model.phone] [text "save"]
    ]

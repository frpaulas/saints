module Saints.Phone ( Model, Phone, init, 
                      makeModel, new, phoneUpdate, phoneDelete,
                      Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json


type alias ID = Int
type alias Phone =
  { id:       ID
  , donor_id: ID
  , location: String
  , ofType:   String
  , number:   String
  }
initPhone: Phone
initPhone =
  { id       = -1
  , donor_id = -1
  , location = ""
  , ofType   = ""
  , number   = ""
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

new: ID -> Model
new donor_id =
  let
    phone = initPhone
    newPhone = {phone | donor_id = donor_id}
  in
    { phone = newPhone
    , editing = True
    }

-- SIGNALS

phoneUpdate: Signal.Mailbox Phone
phoneUpdate =
  Signal.mailbox initPhone

phoneDelete: Signal.Mailbox Phone
phoneDelete =
  Signal.mailbox initPhone


-- UPDATE

type Action 
  = NoOp
  | ToggleEditing
  | Location String
  | OfType String
  | Number String
  | Delete

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
    Location s -> 
      let
        phone = model.phone
        newPhone = {phone | location = s}
      in
        { model | phone = newPhone }
    Number s -> 
      let
        phone = model.phone
        newPhone = {phone | number = s}
      in
        { model | phone = newPhone}
    Delete -> model

-- VIEW
    
view: Signal.Address Action -> Model -> List Html
view address model =
  let phone = model.phone
  in
    [ li 
        [ onClickPhone address ToggleEditing ] 
        [ text (phone.location ++ " " ++ phone.ofType ++ ": " ++ phone.number) 
        , button [ deleteButtonStyle, onClickPhone phoneDelete.address phone ] [ text "-"]
        ]
    , li
      []
      [ ul
        [ editingClass model ]
        [ li 
          [] 
          [ span [] [inputLocation address phone]
          , cancelSave address model
          ]
        , li [] [inputOfType address phone]
        , li [] [inputNumber address phone]
        ]
      ]
    ]

inputLocation: Signal.Address Action -> Phone -> Html
inputLocation address phone =
  p 
    []
    [ input 
      [ id "location"
      , type' "text"
      , placeholder "Location (home, office, etc.)"
      , autofocus True
      , name "location"
      , on "input" targetValue (\str -> Signal.message address (Location str))
      , onClickPhone address NoOp
      , value phone.location
      ]
      []
    ]

inputOfType: Signal.Address Action -> Phone -> Html
inputOfType address phone =
  p 
    []
    [ input 
      [ id "ofType"
      , type' "text"
      , placeholder "Type (phone, email, etc.)"
      , autofocus True
      , name "ofType"
      , on "input" targetValue (\str -> Signal.message address (OfType str))
      , onClickPhone address NoOp
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
      , onClickPhone address NoOp
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
    [ button [ onClickPhone address ToggleEditing] [text "cancel"]
    , button [ onClickPhone phoneUpdate.address model.phone] [text "save"]
    ]

onClickPhone: Signal.Address a -> a -> Attribute
onClickPhone address msg =
  onWithOptions "click" { stopPropagation = True, preventDefault = True } Json.value (\_ -> Signal.message address msg)


-- STYLE

deleteButtonStyle: Attribute
deleteButtonStyle =
  style
        [ ("position", "absolute")
        , ("float", "right")
        , ("right", "1px")
        , ("top", "3px")
        , ("padding", "0px 4px")
        , ("line-height", "0.9")
        , ("display", "inline-block")
        , ("z-index", "1")
        , ("background-color", "red")
        ]

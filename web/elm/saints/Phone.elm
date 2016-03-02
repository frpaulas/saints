module Saints.Phone ( Model, Phone, init, 
                      makeModel, new, phoneUpdate, phoneDelete,
                      Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Saints.Helper exposing (onClickLimited, hideAble)


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


-- VIEW

    
view: Signal.Address Action -> Model -> List Html
view address model =
  let 
    phone = model.phone
  in
    [ li 
        [ onClickLimited address ToggleEditing ] 
        [ text (phone.location ++ " " ++ phone.ofType ++ ": " ++ phone.number) 
        , button 
            [ deleteButtonStyle
            , onClickLimited phoneDelete.address phone 
            ] 
            [ text "delete"]
        ]
    , li
      []
      [ cancelSave address model
      , ul
        [ editingStyle model ]
        [ li [] [inputLocation address phone]
        , li [] [inputOfType address phone]
        , li [] [inputNumber address phone]
        ]
      ]
    ]

inputLocation: Signal.Address Action -> Phone -> Html
inputLocation address phone =
  p 
    [ inputStyle ]
    [ input 
      [ id "location"
      , type' "text"
      , placeholder "Location (home, office, etc.)"
      , autofocus True
      , name "location"
      , on "input" targetValue (\str -> Signal.message address (Location str))
      , onClickLimited address NoOp
      , value phone.location
      , inputWidth "75%"
      ]
      []
    ]

inputOfType: Signal.Address Action -> Phone -> Html
inputOfType address phone =
  p 
    [ inputStyle ]
    [ input 
      [ id "ofType"
      , type' "text"
      , placeholder "Type (phone, email, etc.)"
      , autofocus True
      , name "ofType"
      , on "input" targetValue (\str -> Signal.message address (OfType str))
      , onClickLimited address NoOp
      , value phone.ofType
      , inputWidth "75%"
      ]
      []
    ]

inputNumber: Signal.Address Action -> Phone -> Html
inputNumber address phone =
  p 
    [ inputStyle ]
    [ input 
      [ id "number"
      , type' "text"
      , placeholder "number or email"
      , autofocus True
      , name "number"
      , on "input" targetValue (\str -> Signal.message address (Number str))
      , onClickLimited address NoOp
      , value phone.number
      , inputWidth "75%"
      ]
      []
    ]

cancelSave: Signal.Address Action -> Model -> Html
cancelSave address model = 
  span 
    [ cancelSaveStyle model ]
    [ button [ onClickLimited phoneDelete.address model.phone] [text "cancel"]
    , button [ onClickLimited phoneUpdate.address model.phone] [text "save"]
    ]


-- STYLE


inputWidth: String -> Attribute
inputWidth width =
  style [ ("width", width) ]

editingStyle: Model -> Attribute
editingStyle model =
  hideAble
    model.editing 
    [ ("display", "block") 
    , ("list-style-type", "none")
    , ("font-size", "0.8em")
    , ("padding-bottom", "1px")
    , ("padding-top", "5px")
    ]

cancelSaveStyle: Model -> Attribute
cancelSaveStyle model = 
  hideAble
    model.editing
    [ ( "position", "absolute" )
    , ( "top", "-20px" )
    , ( "left", "0px" )
    , ("line-height", "0.8")
    , ("display", "inline-block")
    ]

inputStyle: Attribute
inputStyle = 
  style
    [ ( "margin-left", "-30px")
    , ( "margin-top", "-8px")
    ]

deleteButtonStyle: Attribute
deleteButtonStyle =
  style
    [ ("margin-right", "-29px")
    , ("float", "right")
    , ("padding", "1px 4px")
    , ("line-height", "0.9")
    , ("display", "inline-block")
    , ("z-index", "1")
    , ("font-size", "0.8em")
    , ("color", "lightyellow")
    , ("background-color", "crimson")
    ]
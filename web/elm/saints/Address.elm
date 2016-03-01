module Saints.Address ( Model, Address, init, makeModel, new, addressUpdate,
                        addressDelete, Action, update, view
                      ) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Graphics.Input exposing (dropDown)
import Json.Decode as Json


type alias ID = Int
type alias Address =
  { id:       ID
  , donor_id: ID
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
  { id = -1
  , donor_id = -1
  , location = ""
  , address1 = ""
  , address2 = ""
  , city =     ""
  , state =    ""
  , zip =      ""
  , country =  ""
  }

type alias Model =
  { address: Address
  , editing: Bool
  }

init: Model
init =
  { address = initAddress
  , editing = False
  }

makeModel: Address -> Model
makeModel addr =
  { address = addr
  , editing = False
  }

new: ID -> Model
new donor_id =
  let
    address = initAddress
    newAddress = {address | donor_id = donor_id}
  in
    { address = newAddress
    , editing = True
    }

-- SIGNALS

addressUpdate: Signal.Mailbox Address
addressUpdate =
  Signal.mailbox initAddress

addressDelete: Signal.Mailbox Address
addressDelete =
  Signal.mailbox initAddress


-- UPDATE

type Action 
  = NoOp
  | ToggleEditing
  | SaveEdit
  | Location String
  | Address1 String
  | Address2 String
  | City String
  | State String
  | Zip String
  | Country String

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ToggleEditing -> {model | editing = not model.editing}
    SaveEdit -> {model | editing = not model.editing}
    Location s -> 
      let
        addr = model.address
        newAddress = {addr | location = s}
      in
        { model | address = newAddress }
    Address1 s -> 
      let
        addr = model.address
        newAddress = {addr | address1 = s}
      in
        { model | address = newAddress }
    Address2 s -> 
      let
        addr = model.address
        newAddress = {addr | address2 = s}
      in
        { model | address = newAddress }
    City s -> 
      let
        addr = model.address
        newAddress = {addr | city = s}
      in
        { model | address = newAddress }
    State s -> 
      let
        addr = model.address
        newAddress = {addr | state = s}
      in
        { model | address = newAddress }
    Zip s  -> 
      let
        addr = model.address
        newAddress = {addr | zip = s}
      in
        { model | address = newAddress }
    Country s -> 
      let
        addr = model.address
        newAddress = {addr | country = s}
      in
        { model | address = newAddress }


-- VIEW

view: Signal.Address Action -> Model -> List Html
view address model =
  let 
    addr = model.address
  in
    [ li [ onClickAddr address ToggleEditing] 
        [ text addr.location
        , button 
            [ deleteButtonStyle
            , onClickAddr addressDelete.address addr 
            ] 
            [ text "delete"]
        , p [] [ text addr.address1 ]
        , p [] [ text addr.address2 ]
        , p [] [ text (addr.city ++ ", " ++ addr.state ++ " " ++ addr.zip) ]
        , p [] [ text addr.country ]
        ]
    , li
      []
      [ cancelSave address model
      , ul 
        [ editingStyle model ] 
        [ li [] [ inputLocation address addr ]
        , li [] [ inputAddress1 address addr ]
        , li [] [ inputAddress2 address addr ]
        , li [] [ inputCity address addr ]
        , li [] [ inputState address addr ]
        , li [] [ inputZip address addr ]
        , li [] [ inputCountry address addr ]
        ]
      ]
    ]


inputLocation: Signal.Address Action -> Address -> Html
inputLocation address model =
  p
    [ inputStyle ]
    [ input 
    [ id "location"
    , type' "text"
    , placeholder "Location"
    , autofocus True
    , name "location"
    , on "input" targetValue (\str -> Signal.message address (Location str))
    , onClickAddr address NoOp
    , value model.location
    , inputWidth "75%"
    ]
    []
  ]

inputAddress1: Signal.Address Action -> Address -> Html
inputAddress1 address model =
  p
    [ inputStyle ]
    [ input 
      [ id "address1"
      , type' "text"
      , placeholder "Street Address"
      , autofocus True
      , name "address1"
      , on "input" targetValue (\str -> Signal.message address (Address1 str))
      , onClickAddr address NoOp
      , value model.address1
      , inputWidth "75%"
      ]
      []
  ]

inputAddress2: Signal.Address Action -> Address -> Html
inputAddress2 address model =
  p
    [ inputStyle ]
    [ input 
      [ id "address2"
      , type' "text"
      , placeholder "Street Address"
      , autofocus True
      , name "address2"
      , on "input" targetValue (\str -> Signal.message address (Address2 str))
      , onClickAddr address NoOp
      , value model.address2
      , inputWidth "75%"
      ]
      []
    ]

inputCity: Signal.Address Action -> Address -> Html
inputCity address model =
  p
    [ inputStyle ]
    [ input 
      [ id "city"
      , type' "text"
      , placeholder "City"
      , autofocus True
      , name "city"
      , on "input" targetValue (\str -> Signal.message address (City str))
      , onClickAddr address NoOp
      , value model.city
      , inputWidth "75%"
      ]
      []
    ]

inputState: Signal.Address Action -> Address -> Html
inputState address model =
  p
    [ inputStyle ]
    [ input 
      [ id "state"
      , type' "text"
      , placeholder "State or Province"
      , autofocus True
      , name "state"
      , on "input" targetValue (\str -> Signal.message address (State str))
      , onClickAddr address NoOp
      , value model.state
      , inputWidth "75%"
      ]
      []
    ]

inputZip: Signal.Address Action -> Address -> Html
inputZip address model =
  p
    [ inputStyle ]
    [ input 
        [ id "zip"
        , type' "text"
        , placeholder "Postal Code"
        , autofocus True
        , name "zip"
        , on "input" targetValue (\str -> Signal.message address (Zip str))
        , onClickAddr address NoOp
        , value model.zip
        , inputWidth "75%"
        ]
        []
      ]

inputCountry: Signal.Address Action -> Address -> Html
inputCountry address model =
  p
    [ inputStyle ]
    [ input 
      [ id "country"
      , type' "text"
      , placeholder "Country"
      , autofocus True
      , name "country"
      , onClickAddr address NoOp
      , on "input" targetValue (\str -> Signal.message address (Country str))
      , value model.country
      , inputWidth "75%"
      ]
      []
    ]
  
cancelSave: Signal.Address Action -> Model -> Html
cancelSave address model = 
  span 
    [ cancelSaveStyle model ]
    [ button [ onClickAddr addressDelete.address model.address] [text "cancel"]
    , button [ onClickAddr addressUpdate.address model.address] [text "save"]
    ]

onClickAddr: Signal.Address a -> a -> Attribute
onClickAddr address msg =
  onWithOptions "click" { stopPropagation = True, preventDefault = True } Json.value (\_ -> Signal.message address msg)


-- STYLE

inputWidth: String -> Attribute
inputWidth width =
  style [ ("width", width) ]

inputStyle: Attribute
inputStyle = 
  style
    [ ( "margin-left", "-30px")
    , ( "margin-top", "-8px")
    ]

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

hideAble: Bool -> List (String, String) -> Attribute
hideAble show attr =
  if show then style attr else style [("display", "none")]


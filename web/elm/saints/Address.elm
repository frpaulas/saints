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
  { id = 0
  , donor_id = 0
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
  | Delete
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
    Delete -> model
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

view: Signal.Address Action -> Model -> List Html
view address model =
  let addr = model.address
  in
    [ li [ onClickAddr address ToggleEditing] 
        [ text addr.location
        , button [ deleteButtonStyle, onClickAddr addressDelete.address addr ] [ text "-"]
        , p [] [ text addr.address1 ]
        , p [] [ text addr.address2 ]
        , p [] [ text (addr.city ++ ", " ++ addr.state ++ " " ++ addr.zip) ]
        , p [] [ text addr.country ]
        ]
    , li
      []
      [ ul 
        [ editingClass model ] 
        [ li 
          [] 
          [ span [] [ inputLocation address addr ]
          , cancelSave address model
          ]
        , li [] [inputAddress1 address addr]
        , li [] [inputAddress2 address addr]
        , li [] [inputCity address addr]
        , li [] [inputState address addr]
        , li [] [inputZip address addr]
        , li [] [inputCountry address addr]
        ]
      ]
    ]


inputLocation: Signal.Address Action -> Address -> Html
inputLocation address model =
  input 
  [ id "location"
  , type' "text"
  , placeholder "Location"
  , autofocus True
  , name "location"
  , on "input" targetValue (\str -> Signal.message address (Location str))
  , value model.location
  ]
  []
  

inputAddress1: Signal.Address Action -> Address -> Html
inputAddress1 address model =
  input 
    [ id "address1"
    , type' "text"
    , placeholder "Street Address"
    , autofocus True
    , name "address1"
    , on "input" targetValue (\str -> Signal.message address (Address1 str))
    , value model.address1
    ]
    []
  

inputAddress2: Signal.Address Action -> Address -> Html
inputAddress2 address model =
  input 
    [ id "address2"
    , type' "text"
    , placeholder "Street Address"
    , autofocus True
    , name "address2"
    , on "input" targetValue (\str -> Signal.message address (Address2 str))
    , value model.address2
    ]
    []
  

inputCity: Signal.Address Action -> Address -> Html
inputCity address model =
  input 
    [ id "city"
    , type' "text"
    , placeholder "City"
    , autofocus True
    , name "city"
    , on "input" targetValue (\str -> Signal.message address (City str))
    , value model.city
    ]
    []
  

inputState: Signal.Address Action -> Address -> Html
inputState address model =
  input 
    [ id "state"
    , type' "text"
    , placeholder "State or Province"
    , autofocus True
    , name "state"
    , on "input" targetValue (\str -> Signal.message address (State str))
    , value model.state
    ]
    []
  

inputZip: Signal.Address Action -> Address -> Html
inputZip address model =
  input 
    [ id "zip"
    , type' "text"
    , placeholder "Postal Code"
    , autofocus True
    , name "zip"
    , on "input" targetValue (\str -> Signal.message address (Zip str))
    , value model.zip
    ]
    []
  

inputCountry: Signal.Address Action -> Address -> Html
inputCountry address model =
  input 
    [ id "country"
    , type' "text"
    , placeholder "Country"
    , autofocus True
    , name "country"
    , on "input" targetValue (\str -> Signal.message address (Country str))
    , value model.country
    ]
    []
  

editingClass: Model -> Html.Attribute
editingClass model =
  class (if model.editing then "edit_details" else "hide")
viewingClass model =
  class (if model.editing then "hide" else "")
cancelSave: Signal.Address Action -> Model -> Html
cancelSave address model = 
  span 
    [ style [("float", "right"), ("margin-top", "-6px")] ]
    [ button [ onClickAddr address ToggleEditing] [text "cancel"]
    , button [ onClickAddr addressUpdate.address model.address] [text "save"]
    ]

onClickAddr: Signal.Address a -> a -> Attribute
onClickAddr address msg =
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


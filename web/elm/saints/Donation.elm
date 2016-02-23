module Saints.Donation (  Model, Donation, init, new,
                          makeModel, donationUpdate, donationDelete, 
                          Action, update, view
                        ) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (concat, join, toInt, split)
import Regex
import Json.Decode as Json

type alias ID = Int
type alias Pennies = String

type alias Donation =
  { id: ID
  , donor_id: ID
  , amount:   Pennies
  , ofType:   String -- e.g. check, cash, paypal
  , ofTypeID: String -- check no., paypal trans. id, etc.
  }
initDonation: Donation
initDonation =
  { id        = -1
  , donor_id  = -1
  , amount    = ""
  , ofType    = "" -- e.g. check, cash, paypal
  , ofTypeID  = "" -- check no., paypal trans. id, etc.
  }

type alias Model =
  { donation: Donation
  , editing: Bool
  }
init: Model
init =
  { donation = initDonation
  , editing = False
  }

makeModel: Donation -> Model
makeModel donation = 
  { donation = donation
  , editing = False
  }

new: ID -> Model
new donor_id =
  let
    donation = initDonation
    newDonation = { donation | donor_id = donor_id}
  in
    { donation = newDonation
    , editing = True
    }
  

-- SIGNALS

donationUpdate: Signal.Mailbox Donation
donationUpdate =
  Signal.mailbox initDonation

donationDelete: Signal.Mailbox Donation
donationDelete =
  Signal.mailbox initDonation


-- UPDATE 

type Action 
  = NoOp
  | ToggleEditing
  | SaveEdit
  | Delete
  | Amount String
  | OfType String
  | OfTypeID String

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ToggleEditing -> { model | editing = not model.editing }
    SaveEdit -> { model | editing = not model.editing }
    Delete -> model
    Amount amt ->
      let
        d = model.donation
        newDonation = { d | amount = amt }
      in
        { model | donation = newDonation}
    OfType s ->
      let
        d = model.donation
        newDonation = { d | ofType = s }
      in
        { model | donation = newDonation }
    OfTypeID s ->
      let
        d = model.donation
        newDonation = { d | ofTypeID = s }
      in
        { model | donation = newDonation }

-- VIEW

view: Signal.Address Action -> Model -> List Html
view address model =
  let
    donation = model.donation
  in
    [ li 
        [ onClickDonation address ToggleEditing ]
        [ donationText donation 
        , button 
            [ deleteButtonStyle, onClickDonation donationDelete.address donation ]
            [ text "-"]
        ]
    , li
        []
        [ cancelSave address model 
        , ul
            [ editingStyle model ]
            [ li [] [ inputAmount address donation ] 
            , li [] [ inputOfType address donation ]
            , li [] [ inputOfTypeID address donation ]
            ]
        ]
    ]

inputAmount: Signal.Address Action -> Donation -> Html
inputAmount address model =
  p
    [ inputStyle ]
    [ input 
    [ id "amount"
    , type' "text"
    , placeholder "Donation"
    , autofocus True
    , name "amount"
    , on "input" targetValue (\str -> Signal.message address (Amount str))
    , onClickDonation address NoOp
    , value model.amount
    , inputWidth "75%"
    ]
    []
  ]

inputOfType: Signal.Address Action -> Donation -> Html
inputOfType address model =
  p
    [ inputStyle ]
    [ input 
    [ id "ofType"
    , type' "text"
    , placeholder "check/paypal/etc."
    , autofocus True
    , name "ofType"
    , on "input" targetValue (\str -> Signal.message address (OfType str))
    , onClickDonation address NoOp
    , value model.ofType
    , inputWidth "75%"
    ]
    []
  ]

inputOfTypeID: Signal.Address Action -> Donation -> Html
inputOfTypeID address model =
  p
    [ inputStyle ]
    [ input 
    [ id "ofTypeID"
    , type' "text"
    , placeholder "check no., etc."
    , autofocus True
    , name "ofTypeID"
    , on "input" targetValue (\str -> Signal.message address (OfTypeID str))
    , onClickDonation address NoOp
    , value model.ofTypeID
    , inputWidth "75%"
    ]
    []
  ]


-- HELPERS

donationText: Donation -> Html
donationText d =
  text (join " " [ d.amount, "from", d.ofType, d.ofTypeID ] )

onClickDonation: Signal.Address a -> a -> Attribute
onClickDonation address msg =
  onWithOptions "click" { stopPropagation = True, preventDefault = True } Json.value (\_ -> Signal.message address msg)

cancelSave: Signal.Address Action -> Model -> Html
cancelSave address model = 
  span 
    [ cancelSaveStyle model ]
    [ button [ onClickDonation donationDelete.address model.donation] [text "cancel"]
    , button [ onClickDonation donationUpdate.address model.donation] [text "save"]
    ]

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

hideAble: Bool -> List (String, String) -> Attribute
hideAble show attr =
  if show then style attr else style [("display", "none")]



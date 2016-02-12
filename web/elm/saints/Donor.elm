module Saints.Donor ( Model, init, Action, update, view, makeModel,
                      donorUpdate, detailsGet, initDonor, Donor,
                      DBDonor, initDBDonor
                    ) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (join)


import Saints.Address as Address
import Saints.Note as Note
import Saints.Phone as Phone

type alias ID = Int
type alias Donor =
  { id:         ID
  , title:      String
  , firstName:  String
  , middleName: String
  , lastName:   String
  , nameExt:    String
  , phones:     List Phone.Model
  , addresses:  List Address.Model
  , notes:      List Note.Model
  }

type alias DBDonor =
  { id:         ID
  , title:      String
  , firstName:  String
  , middleName: String
  , lastName:   String
  , nameExt:    String
  , phones:     List Phone.Phone
  , addresses:  List Address.Address
  , notes:      List Note.Note
  }

emptyDonor =
  { id =         0
  , title =      ""
  , firstName =  ""
  , middleName = ""
  , lastName =   ""
  , nameExt =    ""
  , phones =     []
  , addresses =  []
  , notes =      []
  }

initDonor: Donor
initDonor = emptyDonor

initDBDonor: DBDonor
initDBDonor = emptyDonor

makeModel: Bool -> Bool -> DBDonor -> Model
makeModel hideDetails detailsInHand donor =
  { donor = 
    { id =         donor.id
    , title =      donor.title
    , firstName =  donor.firstName
    , middleName = donor.middleName
    , lastName =   donor.lastName
    , nameExt =    donor.nameExt
    , phones =     List.map Phone.makeModel donor.phones
    , addresses =  List.map Address.makeModel donor.addresses
    , notes =      List.map Note.makeModel donor.notes
    }
  , hideDetails = hideDetails
  , hideEdit = True
  , detailsInHand = detailsInHand
  }

type alias Model =
  { donor: Donor
  , hideDetails: Bool
  , hideEdit: Bool
  , detailsInHand: Bool
  }
init: Model
init =
  { donor = initDonor
  , hideDetails   = True
  , hideEdit      = True
  , detailsInHand = False
  }

-- SIGNALS

donorUpdate: Signal.Mailbox Donor
donorUpdate =
  Signal.mailbox initDonor

detailsGet: Signal.Mailbox Donor
detailsGet =
  Signal.mailbox initDonor


-- UPDATE

type Action 
  = NoOp
  | OK String
  | ToggleDetails
  | ToggleEdit
  | SaveDonor
  | Delete
  | Title String
  | FirstName String
  | MiddleName String
  | LastName String
  | NameExt String
  | ModifyNote ID Note.Action
  | ModifyAddr ID Address.Action
  | ModifyPhone ID Phone.Action
  | NewNote
  | NewAddress
  | NewPhone

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    OK resp ->
      let
        foo = Debug.log "OK RESP" resp
      in
        model
    ToggleDetails -> { model | hideDetails = (not model.hideDetails)}
    ToggleEdit    -> { model | hideEdit = (not model.hideEdit)}
    SaveDonor     -> { model | hideEdit = (not model.hideEdit)}
    Delete        -> model
    Title       s -> 
      let
        donor = model.donor
        newDonor = {donor | title = s}
      in
        { model | donor = newDonor }
    FirstName   s -> 
      let
        donor = model.donor
        newDonor = {donor | firstName = s}
      in
        { model | donor = newDonor }
    MiddleName  s -> 
      let
        donor = model.donor
        newDonor = {donor | middleName = s}
      in
        { model | donor = newDonor }
    LastName    s -> 
      let
        donor = model.donor
        newDonor = {donor | lastName = s}
      in
        { model | donor = newDonor }
    NameExt     s -> 
      let
        donor = model.donor
        newDonor = {donor | nameExt = s}
      in
        { model | donor = newDonor }
    ModifyNote id noteAction ->
      let
        updatedDonor this = 
          {this | notes = updatedDonorNotes this.notes id noteAction}
      in
        {model | donor = updatedDonor model.donor}
    ModifyAddr id addrAction ->
      let
        updatedDonor this = 
          {this | addresses = updatedDonorAddresses this.addresses id addrAction}
      in
        {model | donor = updatedDonor model.donor}
    ModifyPhone id phoneAction ->
      let
        updatedDonor this = 
          {this | phones = updatedDonorPhones this.phones id phoneAction}
      in
        {model | donor = updatedDonor model.donor}
    NewNote -> 
      let
        donor = model.donor
        newDonor = {donor | notes = donor.notes ++ [Note.newNote donor.id]} 
      in
        {model | donor = newDonor}
    NewAddress ->
      let
        donor = model.donor
        newDonor = {donor | addresses = donor.addresses ++ [Address.new donor.id]} 
      in
        {model | donor = newDonor}
    NewPhone ->
      let
        donor = model.donor
        newDonor = {donor | phones = donor.phones ++ [Phone.new donor.id]} 
      in
        {model | donor = newDonor}

updatedDonorNotes: List Note.Model -> ID -> Note.Action -> List Note.Model
updatedDonorNotes notes id action =
  let 
    noteAction this =
      if this.note.id == id
        then Note.update action this
        else this
  in
    List.map noteAction notes

updatedDonorPhones: List Phone.Model -> ID -> Phone.Action -> List Phone.Model
updatedDonorPhones phones id action =
  let 
    phoneAction this =
      if this.phone.id == id
        then Phone.update action this
        else this
  in
    List.map phoneAction phones

updatedDonorAddresses: List Address.Model -> ID -> Address.Action -> List Address.Model
updatedDonorAddresses addresses id action =
  let 
    addrAction this =
      if this.address.id == id
        then Address.update action this
        else this
  in
    List.map addrAction addresses

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  let
    donor  = model.donor
    notes  = List.map (viewNotes address) donor.notes
              |> List.concat
    theseAddresses = List.map (viewAddr address) donor.addresses
              |> List.concat
    phones = List.map (viewPhone address) donor.phones
              |> List.concat
  in
    li 
--      [ onEnterDetails address model, onMouseLeave address ToggleDetails ] 
      [ onClickDetails address model]
      [ span 
        [ onClick address ToggleEdit]
        [ fullNameText donor 
        , button [ deleteButtonStyle model, onClick address Delete ] [ text "-"]
        ]
      , span
          [ style [("float", "right"), ("margin-top", "-6px")] ]
          [ text "$"
          , donation address model
          , saveButton address model
          ]
      , donorNameEdit address model
      , p
        []
        [ button
          [ addButtonStyle model, onClick address NewNote]
          [ text "+"]
        , ul [ detailsClass model] notes
        ] 
      , p
        []
        [ button
          [ addButtonStyle model, onClick address NewAddress]
          [ text "+"]
        , ul [ detailsClass model] theseAddresses
        ]
      , p
        []
        [ button
          [ addButtonStyle model, onClick address NewPhone]
          [ text "+"]
        , ul [ detailsClass model] phones
        ]
--      , donorDetailsFor address model
      ]

viewNotes: Signal.Address Action -> Note.Model -> List Html
viewNotes address model =
  Note.view (Signal.forwardTo address (ModifyNote model.note.id)) model

viewAddr: Signal.Address Action -> Address.Model -> List Html
viewAddr address model =
  Address.view (Signal.forwardTo address (ModifyAddr model.address.id)) model

viewPhone: Signal.Address Action -> Phone.Model -> List Html
viewPhone address model =
  Phone.view (Signal.forwardTo address (ModifyPhone model.phone.id)) model

donation: Signal.Address Action -> Model -> Html
donation address model =
  input 
    [ id "donation"
    , type' "number"
    , placeholder "Donation"
    , autofocus True
    , name "donation"
    , style [("width", "85px"), ("margin-right", "5px")]
    ]
    []

donorNameEdit: Signal.Address Action -> Model -> Html
donorNameEdit address model =
  ul 
  [ editClass model] 
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

onClickDetails: Signal.Address Action -> Model -> Html.Attribute
onClickDetails address model =
  if model.detailsInHand
    then (onClick address ToggleDetails)
    else (onClick detailsGet.address model.donor)

onEnterDetails: Signal.Address Action -> Model -> Html.Attribute
onEnterDetails address model =
  if model.detailsInHand
    then (onMouseEnter address ToggleDetails)
    else (onMouseEnter detailsGet.address model.donor)

editButton: Model -> Html.Attribute
editButton model =
  class (if model.hideEdit then "edit_button" else "hide")

saveButton: Signal.Address Action -> Model -> Html
saveButton address model =
  button
    [ class (if model.hideEdit then "hide" else "save_button")
--    , onClick address SaveDonor
    , onClick donorUpdate.address model.donor
    ]
    [ text "Save"]
editClass: Model -> Html.Attribute
editClass model =
  class (if model.hideEdit then "hide_details" else "edit_details")

detailsClass: Model -> Html.Attribute
detailsClass model =
  class (if model.hideDetails then "hide_details" else "donor_details")

inputTitle: Signal.Address Action -> Model -> Html
inputTitle address model =
  let donor = model.donor
  in
    input 
      [ id "title"
      , type' "text"
      , placeholder "Title"
      , autofocus True
      , name "title"
      , on "input" targetValue (\str -> Signal.message address (Title str))
      , value donor.title
      ]
      []

inputFirstName: Signal.Address Action -> Model -> Html
inputFirstName address model =
  let donor = model.donor
  in
    input 
      [ id "first_name"
      , type' "text"
      , placeholder "First Name"
      , autofocus True
      , name "first_name"
      , on "input" targetValue (\str -> Signal.message address (FirstName str))
      , value donor.firstName
      ]
      []

inputMiddleName: Signal.Address Action -> Model -> Html
inputMiddleName address model =
  let donor = model.donor
  in
    input 
      [ id "middle_name"
      , type' "text"
      , placeholder "Middle Name"
      , autofocus True
      , name "middle_name"
      , on "input" targetValue (\str -> Signal.message address (MiddleName str))
      , value donor.middleName
      ]
      []

inputLastName: Signal.Address Action -> Model -> Html
inputLastName address model =
  let donor = model.donor
  in
    input 
      [ id "last_name"
      , type' "text"
      , placeholder "Last Name"
      , autofocus True
      , name "last_name"
      , on "input" targetValue (\str -> Signal.message address (LastName str))
      , value donor.lastName
      ]
      []

inputNameExt: Signal.Address Action -> Model -> Html
inputNameExt address model =
  let donor = model.donor
  in
    input 
      [ id "name_ext"
      , type' "text"
      , placeholder "Extension"
      , autofocus True
      , name "name_ext"
      , on "input" targetValue (\str -> Signal.message address (NameExt str))
      , value donor.nameExt
      ]
      []


fullNameText: Donor -> Html
fullNameText d =
  text (join " " [d.title, d.firstName, d.middleName, d.lastName, d.nameExt, "(", toString d.id, ")"])

-- STYLE

addButtonStyle: Model -> Attribute
addButtonStyle model =
  if model.hideDetails
    then
      style [("display", "none")]
    else
      style
        [ ("position", "relative")
        , ("float", "left")
        , ("padding", "0px 2px")
        , ("line-height", "0.8")
        , ("display", "inline-block")
        , ("left", "0px")
        , ("top", "0px")
        , ("z-index", "1")
        ]

deleteButtonStyle: Model -> Attribute
deleteButtonStyle model =
  if model.hideDetails
    then
      style [("display", "none")]
    else
      style
            [ ("position", "absolute")
            , ("float", "right")
            , ("right", "1px")
            , ("top", "0px")
            , ("padding", "0px 4px")
            , ("line-height", "0.9")
            , ("display", "inline-block")
            , ("z-index", "1")
            , ("background-color", "red")
            ]

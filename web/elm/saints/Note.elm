module Saints.Note  ( Model, Note, init, makeModel, newNote, Action, 
                     noteUpdate, noteDelete, update, view
                    ) where


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json

type alias ID = Int
type alias Note = 
  { id: ID
  , donor_id: ID
  , author: String
  , memo: String
  , updated_at: String -- not editable
  }
initNote: Note
initNote =
  { id = -1
  , donor_id = -1
  , author = ""
  , memo = ""
  , updated_at = "" -- note editable, comes from DB
  }
type alias Model =
  { note: Note
  , editing: Bool
  , new: Bool
  }
init: Model
init =
  { note = initNote
  , editing = False
  , new = False
  }

makeModel: Note -> Model
makeModel note =
  { note = note
  , editing = False
  , new = False
  }

newNote: ID -> Model
newNote donor_id =
  let
    note = initNote
    newNote = {note | donor_id = donor_id}
  in
    { note = newNote
    , editing = True
    , new = True
    }

-- SIGNALS

noteUpdate: Signal.Mailbox Note
noteUpdate =
  Signal.mailbox initNote

noteDelete: Signal.Mailbox Note
noteDelete = 
  Signal.mailbox initNote



-- UPDATE

type Action 
  = NoOp
  | Memo String
  | Author String
  | ToggleEditing
  | SaveEdit

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    Memo s ->
      let
        note = model.note
        newNote = {note | memo = s}
      in 
        {model | note = newNote}
    Author s ->
      let
        note = model.note
        newNote = {note | author = s}
      in 
        {model | note = newNote}
    ToggleEditing -> {model | editing = not model.editing}
    SaveEdit -> {model | editing = not model.editing}


-- VIEW

view: Signal.Address Action -> Model -> List Html
view address model =
  let 
    note = model.note
  in
    [ li 
      [ onClickNote address ToggleEditing, viewingStyle model ] 
      [ text (note.author ++ " says: " ++ note.memo)
      , span 
        [ style [("float", "right")]] 
        [ text ("at: " ++ note.updated_at)
        , button [ deleteButtonStyle, onClickNote noteDelete.address note ] [ text "-"]
        ]
      ]
    , li 
      []
      [ ul
        [editingStyle model] 
        [ li
          [editingStyle model]
          [ cancelSave address model
          , inputMemo address note
          ]
        ]
      ]
    ]

inputMemo: Signal.Address Action -> Note -> Html
inputMemo address note =
  input 
    [ id "memo"
    , type' "text"
    , placeholder "Memo"
    , autofocus True
    , name "memo"
    , on "input" targetValue (\str -> Signal.message address (Memo str))
    , onClickNote address NoOp
    , value note.memo
    , inputStyle
    ]
    []

cancelSave: Signal.Address Action -> Model -> Html
cancelSave address model = 
  span 
    [ cancelSaveStyle ]
    [ button [ onClickNote noteDelete.address model.note] [text "cancel"]
    , button [ onClickNote noteUpdate.address model.note] [text "save"]
    ]

onClickNote: Signal.Address a -> a -> Attribute
onClickNote address msg =
  onWithOptions "click" { stopPropagation = True, preventDefault = True } Json.value (\_ -> Signal.message address msg)

-- STYLE

inputStyle: Attribute
inputStyle = 
  style 
  [ ("background-color", "lightblue")
  , ("margin-top","5px")
  , ("margin-left", "-100px")
  , ("margin-bottom", "5px")
  ]

cancelSaveStyle: Attribute
cancelSaveStyle =
  style
    [ ("float", "left")
    , ("margin-top", "-15px")
    , ("padding", "0")
    , ("background-color", "lightblue")
    ]

viewingStyle: Model -> Attribute
viewingStyle model =
  if model.editing
    then
      style [("display", "none")]
    else
      style
      [ ("margin-top", "0px")
      , ("list-style-type", "none")
      , ("background", "WhiteSmoke")
      ]

editingStyle: Model -> Attribute
editingStyle model =
  if model.editing
    then
      style
      [ ("display", "block")
      , ("list-style-type", "none")
      , ("font-size", "0.8em")
--      , ("padding-bottom", "10px")
      ]
    else
      style [("display", "none")]

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

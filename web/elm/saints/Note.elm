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
  { id = 0
  , donor_id = 0
  , author = ""
  , memo = ""
  , updated_at = "" -- note editable, comes from DB
  }
type alias Model =
  { note: Note
  , editing: Bool
  }
init: Model
init =
  { note = initNote
  , editing = False
  }

makeModel: Note -> Model
makeModel note =
  { note = note
  , editing = False
  }

newNote: ID -> Model
newNote donor_id =
  let
    note = initNote
    newNote = {note | donor_id = donor_id}
  in
    { note = newNote
    , editing = True
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
  let note = model.note
  in
    [ li 
      [ onClickNote address ToggleEditing, viewingClass model ] 
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
        [editingClass model] 
        [ li
          [editingClass model]
          [inputMemo address note]
        , cancelSave address model
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
    , value note.memo
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
    [ button [ onClickNote address ToggleEditing] [text "cancel"]
    , button [ onClickNote noteUpdate.address model.note] [text "save"]
    ]

onClickNote: Signal.Address a -> a -> Attribute
onClickNote address msg =
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

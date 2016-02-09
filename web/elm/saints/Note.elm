module Saints.Note  ( Model, Note, init, makeModel, Action, 
                     noteUpdate, update, view
                    ) where


import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias ID = Int
type alias Note = 
  { id: ID
  , memo: String
  }
initNote: Note
initNote =
  { id = 0
  , memo = ""
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

-- SIGNALS

noteUpdate: Signal.Mailbox Note
noteUpdate =
  Signal.mailbox initNote



-- UPDATE

type Action 
  = NoOp
  | Memo String
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
    ToggleEditing -> {model | editing = not model.editing}
    SaveEdit ->
      let 
        foo = Debug.log "SAVE EDIT: " model
        updatedModel = {model | editing = not model.editing}
      in
        updatedModel


-- VIEW

view: Signal.Address Action -> Model -> List Html
view address model =
  let note = model.note
  in
    [ li 
      [ onClick address ToggleEditing, viewingClass model ] 
      [ text note.memo ]
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
    [ button [ onClick address ToggleEditing] [text "cancel"]
    , button [ onClick noteUpdate.address model.note] [text "save"]
    ]

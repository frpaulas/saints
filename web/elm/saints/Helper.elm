module Saints.Helper where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json

-- cancelSave: Signal.Address a -> {a | } -> Html
--cancelSave address model = 
--  span 
--    [ cancelSaveStyle ]
--    [ button [ onClickLimited address model] [text "cancel"]
--    , button [ onClickLimited address model] [text "save"]
--    ]

-- onClickLimited: Signal.Address a -> a -> Attribute
onClickLimited address msg =
  onWithOptions "click" { stopPropagation = True, preventDefault = True } Json.value (\_ -> Signal.message address msg)

-- hideAble: Bool -> List (String, String) -> Attribute
hideAble show attr =
  if show then style attr else style [("display", "none")]

-- STYLE

-- cancelSaveStyle: { a | editing : Bool } -> Attribute
-- cancelSaveStyle model = 
--   hideAble
--     model.editing
-- cancelSaveStyle = 
--   style
--   [ ( "position", "absolute" )
--   , ( "top", "-20px" )
--   , ( "left", "0px" )
--   , ("line-height", "0.8")
--   , ("display", "inline-block")
--   ]


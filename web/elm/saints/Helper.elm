module Saints.Helper where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json


onClickLimited: Signal.Address a -> a -> Attribute
onClickLimited address msg =
  onWithOptions "click" { stopPropagation = True, preventDefault = True } Json.value (\_ -> Signal.message address msg)

hideAble: Bool -> List (String, String) -> Attribute
hideAble show attr =
  if show then style attr else style [("display", "none")]



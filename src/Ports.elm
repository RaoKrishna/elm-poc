port module Ports exposing (formatTime)

import Json.Encode as JE exposing (..)


port formatTime : String -> Cmd msg

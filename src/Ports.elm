port module Ports exposing (formatTime)

import Json.Encode as JE exposing (..)


port formatTime : JE.Value -> Cmd msg

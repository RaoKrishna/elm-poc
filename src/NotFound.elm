module NotFound exposing (Msg, init, update, view)

import Browser
import Html exposing (Html, div, h1, img, table, td, text, th, tr)
import Html.Attributes exposing (src, style)



---- MODEL ----


init : Cmd Msg
init =
    Cmd.none



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Cmd Msg
update msg =
    case msg of
        NoOp ->
            Cmd.none



---- VIEW ----


view : { title : String, body : List (Html Msg) }
view =
    { title = "Not Found"
    , body =
        [ div []
            [ h1 [] [ text "Page not found!" ]
            ]
        ]
    }

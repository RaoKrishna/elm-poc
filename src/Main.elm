module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, div, h1, img, table, td, text, th, tr)
import Html.Attributes exposing (src, style)
import Http
import Json.Decode as Decode exposing (Decoder)



---- MODEL ----


type alias Model =
    List VisitorActivity


type alias VisitorActivity =
    { visitorId : Int
    , activityType : String
    , activityName : String
    }


init : ( Model, Cmd Msg )
init =
    ( [ { visitorId = 0
        , activityType = "First type"
        , activityName = "First Name"
        }
      ]
    , getVisitorActivities
    )



---- UPDATE ----


type Msg
    = NoOp
    | GetActivities (Result Http.Error (List VisitorActivity))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetActivities result ->
            case result of
                Ok activities ->
                    ( activities
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ table
            []
            (generateRows model)
        ]


generateRows : Model -> List (Html Msg)
generateRows model =
    let
        rows =
            List.map
                (\element ->
                    tr []
                        [ td [] [ text (String.fromInt element.visitorId) ]
                        , td [] [ text element.activityType ]
                        , td [] [ text element.activityName ]
                        ]
                )
                model

        header =
            tr []
                [ th [] [ text "Visitor Id" ]
                , th [] [ text "Activity Type" ]
                , th [] [ text "Activity Name" ]
                ]
    in
    header :: rows



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }



---- HTTP ----


getVisitorActivities : Cmd Msg
getVisitorActivities =
    Http.send GetActivities getActivitesRequest


getActivitesRequest : Http.Request (List VisitorActivity)
getActivitesRequest =
    Http.request
        { method = "GET"
        , headers = [ Http.header "x-authorization-token" "baENwmkjKr6icweK9Y2hTf" ]
        , url = "https://api.qa.lookbookhq.com/public/v1/visitor_activities"
        , body = Http.emptyBody
        , expect = Http.expectJson activitiesDecoder
        , timeout = Nothing
        , withCredentials = False
        }


activitiesDecoder : Decoder (List VisitorActivity)
activitiesDecoder =
    Decode.field "data" (Decode.list activityDecoder)


activityDecoder : Decoder VisitorActivity
activityDecoder =
    Decode.map3 VisitorActivity
        (Decode.field "visitor_id" Decode.int)
        (Decode.field "activity_type" Decode.string)
        (Decode.field "activity_name" Decode.string)

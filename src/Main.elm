module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser as Parser exposing ((</>), Parser, custom, fragment, map, oneOf, s, top)
import Visitor



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



---- MODEL ----


type alias Model =
    { key : Nav.Key
    , page : Page
    }


type Page
    = Visitor Visitor.Model


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    -- stepUrl url
    --     { key = key
    --     , page = Visitor Visitor.initialModel
    --     }
    stepVisitor
        { key = key
        , page = Visitor Visitor.initialModel
        }
        Visitor.init


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | VisitorMsg Visitor.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            stepUrl url model

        VisitorMsg visitorMsg ->
            case model.page of
                Visitor visitor ->
                    stepVisitor model (Visitor.update visitorMsg visitor)



-- _ ->
--     ( model, Cmd.none )
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage toMsg pageView =
            { title = pageView.title
            , body = List.map (Html.map toMsg) pageView.body
            }
    in
    case model.page of
        Visitor visitorModel ->
            viewPage VisitorMsg (Visitor.view visitorModel)



-- viewPage : (a -> msg) -> Details a -> Browser.Document msg
-- viewPage toMsg details =
--   { title =
--       details.title
--   , body =
--       [ viewHeader details.header
--       , lazy viewWarning details.warning
--       , Html.map toMsg <|
--           div (class "center" :: details.attrs) details.kids
--       , viewFooter
--       ]
--   }
-- ROUTER


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        parser =
            oneOf
                []
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( { model | page = Visitor Visitor.initialModel }
            , Cmd.none
            )


stepVisitor : Model -> ( Visitor.Model, Cmd Visitor.Msg ) -> ( Model, Cmd Msg )
stepVisitor model ( visitor, cmds ) =
    ( { model | page = Visitor visitor }
    , Cmd.map VisitorMsg cmds
    )

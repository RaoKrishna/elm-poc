module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import NotFound
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
    | NotFound


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    changeUrl url
        { key = key
        , page = Visitor Visitor.initialModel
        }



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | VisitorMsg Visitor.Msg
    | NotFoundMsg NotFound.Msg


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
            changeUrl url model

        VisitorMsg visitorMsg ->
            case model.page of
                Visitor visitor ->
                    goToVisitor model (Visitor.update visitorMsg visitor)

                _ ->
                    ( model, Cmd.none )

        NotFoundMsg notFoundMsg ->
            case model.page of
                NotFound ->
                    goToNotFound model (NotFound.update notFoundMsg)

                _ ->
                    ( model, Cmd.none )



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

        NotFound ->
            viewPage NotFoundMsg NotFound.view



-- ROUTER


changeUrl : Url.Url -> Model -> ( Model, Cmd Msg )
changeUrl url model =
    case url.path of
        "/" ->
            goToVisitor model Visitor.init

        "/visitor" ->
            goToVisitor model Visitor.init

        _ ->
            goToNotFound model NotFound.init


goToVisitor : Model -> ( Visitor.Model, Cmd Visitor.Msg ) -> ( Model, Cmd Msg )
goToVisitor model ( visitor, cmds ) =
    ( { model | page = Visitor visitor }
    , Cmd.map VisitorMsg cmds
    )


goToNotFound : Model -> Cmd NotFound.Msg -> ( Model, Cmd Msg )
goToNotFound model cmds =
    ( { model | page = NotFound }
    , Cmd.map NotFoundMsg cmds
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

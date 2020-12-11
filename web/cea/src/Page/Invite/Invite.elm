module Page.Invite.Invite exposing (..)

import EndPoint as EP
import Html exposing (..)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Page as P
import Util as U



-- MODEL


type alias Mdl =
    { email : String
    , msg : String
    }


init : ( Mdl, Cmd Msg )
init =
    ( { email = "", msg = "" }, Cmd.none )



-- UPDATE


type Msg
    = Goto P.Page
    | FromU FromU
    | FromS FromS


type FromU
    = InviteMe
    | EditEmail String


type FromS
    = InvitedYou (U.HttpResult ())


update : Msg -> Mdl -> ( Mdl, Cmd Msg )
update msg mdl =
    case msg of
        FromU fromU ->
            case fromU of
                InviteMe ->
                    ( mdl, invite mdl.email )

                EditEmail s ->
                    ( { mdl | email = s }, Cmd.none )

        FromS fromS ->
            case fromS of
                InvitedYou (Err e) ->
                    ( { mdl | msg = U.strHttpError e }, Cmd.none )

                InvitedYou (Ok _) ->
                    ( mdl, U.cmd Goto (P.Register_ P.Register) )

        _ ->
            ( mdl, Cmd.none )


type alias Email =
    String


invite : Email -> Cmd Msg
invite e =
    U.post_ EP.Invite (encEmail e) (FromS << InvitedYou)


encEmail : Email -> Encode.Value
encEmail e =
    Encode.object
        [ ( "email", Encode.string e )
        , ( "reset", Encode.bool False )
        ]



-- VIEW


view : Mdl -> Html Msg
view mdl =
    Html.map FromU <|
        div []
            [ div [] [ text "Invite" ]
            , U.input "email" "Email" mdl.email EditEmail
            , button [ onClick InviteMe ] [ text "InviteMe" ]
            , div [] [ text mdl.msg ]
            ]



-- SUBSCRIPTIONS


subscriptions : Mdl -> Sub Msg
subscriptions mdl =
    Sub.none



-- HELPER

module Page.Login exposing (..)

import EndPoint as EP
import Html exposing (..)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Page as P
import Util as U



-- MODEL


type alias Mdl =
    { cred : Cred
    , msg : String
    }


type alias Cred =
    { email : String
    , password : String
    }


init : ( Mdl, Cmd Msg )
init =
    ( { cred = { email = "", password = "" }, msg = "" }, Cmd.none )



-- UPDATE


type Msg
    = Goto P.Page
    | FromU FromU
    | FromS FromS


type FromU
    = Login
    | NoAccount
    | ForgotPW
    | EditEmail String
    | EditPassWord String


type FromS
    = LoggedIn (U.HttpResult ())


update : Msg -> Mdl -> ( Mdl, Cmd Msg )
update msg mdl =
    case msg of
        FromU fromU ->
            case fromU of
                Login ->
                    ( mdl, login mdl.cred )

                NoAccount ->
                    ( mdl, U.cmd Goto (P.Invite_ P.Invite) )

                ForgotPW ->
                    ( mdl, U.cmd Goto (P.Invite_ P.ForgotPW) )

                EditEmail s ->
                    let
                        cred =
                            mdl.cred

                        newCred =
                            { cred | email = s }
                    in
                    ( { mdl | cred = newCred }, Cmd.none )

                EditPassWord s ->
                    let
                        cred =
                            mdl.cred

                        newCred =
                            { cred | password = s }
                    in
                    ( { mdl | cred = newCred }, Cmd.none )

        FromS fromS ->
            case fromS of
                LoggedIn (Err e) ->
                    ( { mdl | msg = U.strHttpError e }, Cmd.none )

                LoggedIn (Ok _) ->
                    ( mdl, U.cmd Goto P.LP )

        _ ->
            ( mdl, Cmd.none )


login : Cred -> Cmd Msg
login c =
    U.post_ EP.Auth (encCred c) (FromS << LoggedIn)


encCred : Cred -> Encode.Value
encCred c =
    Encode.object
        [ ( "email", Encode.string c.email )
        , ( "password", Encode.string c.password )
        ]



-- VIEW


view : Mdl -> Html Msg
view mdl =
    Html.map FromU <|
        div []
            [ div [] [ text "Login" ]
            , U.input "email" "Email" mdl.cred.email EditEmail
            , U.input "password" "PassWord" mdl.cred.password EditPassWord
            , button [ onClick Login ] [ text "Login" ]
            , button [ onClick NoAccount ] [ text "NoAccount" ]

            -- TODO implement server side
            -- , button [ onClick ForgotPW ] [ text "ForgotPW" ]
            , div [] [ text mdl.msg ]
            ]



-- SUBSCRIPTIONS


subscriptions : Mdl -> Sub Msg
subscriptions mdl =
    Sub.none



-- HELPER

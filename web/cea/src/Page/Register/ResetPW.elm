module Page.Register.ResetPW exposing (..)

import EndPoint as EP
import Html exposing (..)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Page as P
import Util as U



-- MODEL


type alias Mdl =
    { key : String
    , password : String
    , confirmation : String
    , msg : String
    }


init : ( Mdl, Cmd Msg )
init =
    ( { key = "", password = "", confirmation = "", msg = "" }, Cmd.none )



-- UPDATE


type Msg
    = Goto P.Page
    | FromU FromU
    | FromS FromS


type FromU
    = RegisterMe
    | EditKey String
    | EditPassWord String
    | EditConfirmation String


type FromS
    = RegisteredYou (U.HttpResult ())


update : Msg -> Mdl -> ( Mdl, Cmd Msg )
update msg mdl =
    case msg of
        FromU fromU ->
            case fromU of
                RegisterMe ->
                    case faultOf mdl of
                        Just fault ->
                            ( { mdl | msg = fault }, Cmd.none )

                        _ ->
                            ( mdl, register mdl )

                EditKey s ->
                    ( { mdl | key = s }, Cmd.none )

                EditPassWord s ->
                    ( { mdl | password = s }, Cmd.none )

                EditConfirmation s ->
                    ( { mdl | confirmation = s }, Cmd.none )

        FromS fromS ->
            case fromS of
                RegisteredYou (Err e) ->
                    ( { mdl | msg = U.strHttpError e }, Cmd.none )

                RegisteredYou (Ok _) ->
                    ( mdl, U.cmd Goto P.LP )

        _ ->
            ( mdl, Cmd.none )


faultOf : Mdl -> Maybe String
faultOf mdl =
    if mdl.password /= mdl.confirmation then
        Just "Password mismatched"

    else if String.length mdl.password < 8 then
        Just "Password should be at least 8 length"

    else if String.length mdl.key /= 36 then
        Just "Enter the register/reset key correctly"

    else
        Nothing


register : Mdl -> Cmd Msg
register mdl =
    U.post_ (EP.Register mdl.key) (encPW mdl.password) (FromS << RegisteredYou)


type alias PassWord =
    String


encPW : PassWord -> Encode.Value
encPW p =
    Encode.object
        [ ( "password", Encode.string p )
        , ( "reset", Encode.bool True )
        ]



-- VIEW


view : Mdl -> Html Msg
view mdl =
    Html.map FromU <|
        div []
            [ div [] [ text "ResetPW" ]
            , U.input "password" "ResetKey" mdl.key EditKey
            , U.input "password" "PassWord" mdl.password EditPassWord
            , U.input "password" "Confirmation" mdl.confirmation EditConfirmation
            , button [ onClick RegisterMe ] [ text "ResetMe" ]
            , div [] [ text mdl.msg ]
            ]



-- SUBSCRIPTIONS


subscriptions : Mdl -> Sub Msg
subscriptions mdl =
    Sub.none



-- HELPER

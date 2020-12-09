module Util exposing (..)

import Config
import EndPoint as EP
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Task


strEP : EP.EndPoint -> String
strEP ep =
    Config.epBase
        ++ "/"
        ++ (case ep of
                EP.Invite ->
                    "invite"

                EP.Register key ->
                    "register" ++ "/" ++ key

                EP.Auth ->
                    "auth"

                EP.App ->
                    "app"
           )


type alias HttpResult a =
    Result Http.Error a


get : EP.EndPoint -> (HttpResult a -> msg) -> Decoder a -> Cmd msg
get ep resMsg dec =
    Http.get
        { url = strEP ep
        , expect = Http.expectJson resMsg dec
        }


post : EP.EndPoint -> Encode.Value -> (HttpResult a -> msg) -> Decoder a -> Cmd msg
post ep enc resMsg dec =
    Http.post
        { url = strEP ep
        , body = Http.jsonBody enc
        , expect = Http.expectJson resMsg dec
        }


post_ : EP.EndPoint -> Encode.Value -> (HttpResult () -> msg) -> Cmd msg
post_ ep enc resMsg =
    Http.post
        { url = strEP ep
        , body = Http.jsonBody enc
        , expect = Http.expectWhatever resMsg
        }


delete : EP.EndPoint -> (HttpResult () -> msg) -> Cmd msg
delete ep resMsg =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = strEP ep
        , body = Http.emptyBody
        , expect = Http.expectWhatever resMsg
        , timeout = Nothing
        , tracker = Nothing
        }


strHttpError : Http.Error -> String
strHttpError e =
    case e of
        Http.BadUrl msg ->
            msg

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadStatus code ->
            "BadStatus " ++ String.fromInt code

        Http.BadBody msg ->
            msg


cmd : (a -> msg) -> a -> Cmd msg
cmd msgFrom x =
    Task.perform msgFrom (Task.succeed x)


map : (a -> mdl) -> (b -> msg) -> ( a, Cmd b ) -> ( mdl, Cmd msg )
map toMdl toMsg =
    Tuple.mapBoth toMdl (Cmd.map toMsg)


input : String -> String -> String -> (String -> msg) -> Html msg
input t p v toMsg =
    Html.input [ type_ t, placeholder p, value v, onInput toMsg ] []

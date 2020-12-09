module EndPoint exposing (..)


type EndPoint
    = Invite
    | Register Key
    | Auth
    | App


type alias Key =
    String

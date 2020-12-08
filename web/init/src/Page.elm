module Page exposing (..)


type Page
    = LP
    | Invite_ Invite
    | Register_ Register
    | Login
    | App_ App


type Invite
    = Invite
    | ForgotPW


type Register
    = Register
    | ResetPW


type App
    = App

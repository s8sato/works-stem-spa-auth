module Div.A exposing (..)

import Html exposing (Html)
import Html.Attributes exposing (id)
import Page as P
import Page.App.App as App
import Page.Invite.ForgotPW as ForgotPW
import Page.Invite.Invite as Invite
import Page.LP as LP
import Page.Login as Login
import Page.Register.Register as Register
import Page.Register.ResetPW as ResetPW
import Util as U



-- MODEL


type Mdl
    = LPMdl LP.Mdl
    | InviteMdl_ InviteMdl
    | RegisterMdl_ RegisterMdl
    | LoginMdl Login.Mdl
    | AppMdl_ AppMdl


type InviteMdl
    = InviteMdl Invite.Mdl
    | ForgotPWMdl ForgotPW.Mdl


type RegisterMdl
    = RegisterMdl Register.Mdl
    | ResetPWMdl ResetPW.Mdl


type AppMdl
    = AppMdl App.Mdl


init : ( Mdl, Cmd Msg )
init =
    LP.init |> U.map LPMdl LPMsg



-- UPDATE


type Msg
    = LPMsg LP.Msg
    | InviteMsg_ InviteMsg
    | RegisterMsg_ RegisterMsg
    | LoginMsg Login.Msg
    | AppMsg_ AppMsg


type InviteMsg
    = InviteMsg Invite.Msg
    | ForgotPWMsg ForgotPW.Msg


type RegisterMsg
    = RegisterMsg Register.Msg
    | ResetPWMsg ResetPW.Msg


type AppMsg
    = AppMsg App.Msg


update : Msg -> Mdl -> ( Mdl, Cmd Msg )
update msg mdl =
    case findGoto msg of
        Just page ->
            goto page mdl

        _ ->
            case ( msg, mdl ) of
                ( LPMsg msg_, LPMdl mdl_ ) ->
                    LP.update msg_ mdl_ |> U.map LPMdl LPMsg

                ( InviteMsg_ (InviteMsg msg_), InviteMdl_ (InviteMdl mdl_) ) ->
                    Invite.update msg_ mdl_ |> U.map (InviteMdl_ << InviteMdl) (InviteMsg_ << InviteMsg)

                ( InviteMsg_ (ForgotPWMsg msg_), InviteMdl_ (ForgotPWMdl mdl_) ) ->
                    ForgotPW.update msg_ mdl_ |> U.map (InviteMdl_ << ForgotPWMdl) (InviteMsg_ << ForgotPWMsg)

                ( RegisterMsg_ (RegisterMsg msg_), RegisterMdl_ (RegisterMdl mdl_) ) ->
                    Register.update msg_ mdl_ |> U.map (RegisterMdl_ << RegisterMdl) (RegisterMsg_ << RegisterMsg)

                ( RegisterMsg_ (ResetPWMsg msg_), RegisterMdl_ (ResetPWMdl mdl_) ) ->
                    ResetPW.update msg_ mdl_ |> U.map (RegisterMdl_ << ResetPWMdl) (RegisterMsg_ << ResetPWMsg)

                ( LoginMsg msg_, LoginMdl mdl_ ) ->
                    Login.update msg_ mdl_ |> U.map LoginMdl LoginMsg

                ( AppMsg_ (AppMsg msg_), AppMdl_ (AppMdl mdl_) ) ->
                    App.update msg_ mdl_ |> U.map (AppMdl_ << AppMdl) (AppMsg_ << AppMsg)

                _ ->
                    ( mdl, Cmd.none )



-- VIEW


view : Mdl -> Html Msg
view mdl =
    Html.div [ id "div0" ]
        [ case mdl of
            LPMdl m ->
                LP.view m |> Html.map LPMsg

            InviteMdl_ (InviteMdl m) ->
                Invite.view m |> Html.map (InviteMsg_ << InviteMsg)

            InviteMdl_ (ForgotPWMdl m) ->
                ForgotPW.view m |> Html.map (InviteMsg_ << ForgotPWMsg)

            RegisterMdl_ (RegisterMdl m) ->
                Register.view m |> Html.map (RegisterMsg_ << RegisterMsg)

            RegisterMdl_ (ResetPWMdl m) ->
                ResetPW.view m |> Html.map (RegisterMsg_ << ResetPWMsg)

            LoginMdl m ->
                Login.view m |> Html.map LoginMsg

            AppMdl_ (AppMdl m) ->
                App.view m |> Html.map (AppMsg_ << AppMsg)
        ]



-- SUBSCRIPTIONS


subscriptions : Mdl -> Sub Msg
subscriptions mdl =
    case mdl of
        LPMdl m ->
            LP.subscriptions m |> Sub.map LPMsg

        InviteMdl_ (InviteMdl m) ->
            Invite.subscriptions m |> Sub.map (InviteMsg_ << InviteMsg)

        InviteMdl_ (ForgotPWMdl m) ->
            ForgotPW.subscriptions m |> Sub.map (InviteMsg_ << ForgotPWMsg)

        RegisterMdl_ (RegisterMdl m) ->
            Register.subscriptions m |> Sub.map (RegisterMsg_ << RegisterMsg)

        RegisterMdl_ (ResetPWMdl m) ->
            ResetPW.subscriptions m |> Sub.map (RegisterMsg_ << ResetPWMsg)

        LoginMdl m ->
            Login.subscriptions m |> Sub.map LoginMsg

        AppMdl_ (AppMdl m) ->
            App.subscriptions m |> Sub.map (AppMsg_ << AppMsg)



-- HELPER


findGoto : Msg -> Maybe P.Page
findGoto msg =
    case msg of
        LPMsg (LP.Goto page) ->
            Just page

        InviteMsg_ (InviteMsg (Invite.Goto page)) ->
            Just page

        InviteMsg_ (ForgotPWMsg (ForgotPW.Goto page)) ->
            Just page

        RegisterMsg_ (RegisterMsg (Register.Goto page)) ->
            Just page

        RegisterMsg_ (ResetPWMsg (ResetPW.Goto page)) ->
            Just page

        LoginMsg (Login.Goto page) ->
            Just page

        AppMsg_ (AppMsg (App.Goto page)) ->
            Just page

        _ ->
            Nothing


goto : P.Page -> Mdl -> ( Mdl, Cmd Msg )
goto page mdl =
    case page of
        P.LP ->
            LP.init |> U.map LPMdl LPMsg

        P.Invite_ P.Invite ->
            Invite.init |> U.map (InviteMdl_ << InviteMdl) (InviteMsg_ << InviteMsg)

        P.Invite_ P.ForgotPW ->
            ForgotPW.init |> U.map (InviteMdl_ << ForgotPWMdl) (InviteMsg_ << ForgotPWMsg)

        P.Register_ P.Register ->
            case mdl of
                InviteMdl_ (InviteMdl m) ->
                    Register.init m.email |> U.map (RegisterMdl_ << RegisterMdl) (RegisterMsg_ << RegisterMsg)

                _ ->
                    ( mdl, Cmd.none )

        P.Register_ P.ResetPW ->
            ResetPW.init |> U.map (RegisterMdl_ << ResetPWMdl) (RegisterMsg_ << ResetPWMsg)

        P.Login ->
            Login.init |> U.map LoginMdl LoginMsg

        P.App_ P.App ->
            case mdl of
                LPMdl m ->
                    App.init m.user |> U.map (AppMdl_ << AppMdl) (AppMsg_ << AppMsg)

                _ ->
                    ( mdl, Cmd.none )

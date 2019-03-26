port module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as JD



-- ---------------------------
-- MODEL
-- ---------------------------


type alias User =
    { username : String
    , email : String
    , password : String
    }


type alias SignInUser =
    { username : String
    , password : String
    }


type alias ConfirmInfo =
    { username : String
    , code : String
    }


type alias Model =
    { username : String
    , code : String
    , email : String
    , password : String
    , token : String
    , apiBaseUrl : String
    , pets : List Pet
    }


type alias Flags =
    { apiBaseUrl : String
    }


type alias Pet =
    { id : Int
    , animalType : String
    , price : Float
    }


init : Flags -> ( Model, Cmd Msg )
init { apiBaseUrl } =
    ( Model "" "" "" "" "" apiBaseUrl [], Cmd.none )


port signup : User -> Cmd msg


port signin : SignInUser -> Cmd msg


port confirm : ConfirmInfo -> Cmd msg


port sendToken : (String -> msg) -> Sub msg


port signout : () -> Cmd msg



-- ---------------------------
-- UPDATE
-- ---------------------------


getPets : String -> String -> Cmd Msg
getPets apiBaseUrl token =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Authorization" token
            ]
        , url = apiBaseUrl ++ "/pets"
        , body = Http.emptyBody
        , expect = Http.expectJson GotPets decodePets
        , timeout = Nothing
        , tracker = Nothing
        }


decodePets : JD.Decoder (List Pet)
decodePets =
    JD.list decodePet


decodePet : JD.Decoder Pet
decodePet =
    JD.map3 Pet
        (JD.field "id" JD.int)
        (JD.field "type" JD.string)
        (JD.field "price" JD.float)


type Msg
    = SignUp
    | Confirm
    | SignIn
    | SignOut
    | UpdateUserName String
    | UpdateEmail String
    | UpdatePassword String
    | UpdateCode String
    | GetToken String
    | GotPets (Result Http.Error (List Pet))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ username, email, password, code, token, apiBaseUrl } as model) =
    case msg of
        SignUp ->
            ( model, signup { username = username, email = email, password = password } )

        Confirm ->
            ( model, confirm { username = username, code = code } )

        SignIn ->
            ( model, signin { username = username, password = password } )

        SignOut ->
            ( model, signout () )

        UpdateUserName uname ->
            ( { model | username = uname }, Cmd.none )

        UpdateEmail em ->
            ( { model | email = em }, Cmd.none )

        UpdatePassword pwd ->
            ( { model | password = pwd }, Cmd.none )

        UpdateCode c ->
            ( { model | code = c }, Cmd.none )

        GetToken t ->
            ( { model | token = t }, getPets apiBaseUrl t )

        GotPets result ->
            case result of
                Ok pets ->
                    ( { model | pets = pets }, Cmd.none )

                Err e ->
                    ( model, Cmd.none )



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view { username, password, email, code, pets } =
    div [ class "container" ]
        [ div []
            [ input [ placeholder "username", onInput UpdateUserName, value username ] []
            , input [ placeholder "email", type_ "email", onInput UpdateEmail, value email ] []
            , input [ placeholder "password", type_ "password", onInput UpdatePassword, value password ] []
            , input [ type_ "button", value "sign up !!", onClick SignUp ] []
            ]
        , div []
            [ input [ placeholder "username", onInput UpdateUserName, value username ] []
            , input [ placeholder "code", type_ "number", onInput UpdateCode, value code ] []
            , input [ type_ "button", value "confirm !!", onClick Confirm ] []
            ]
        , div []
            [ input [ placeholder "username", onInput UpdateUserName, value username ] []
            , input [ placeholder "password", type_ "password", onInput UpdatePassword, value password ] []
            , input [ type_ "button", value "sign in !!", onClick SignIn ] []
            ]
        , div []
            [ input [ type_ "button", value "sign out !!!", onClick SignOut ] []
            ]
        , ul [] <|
            List.map
                (\{ id, animalType, price } ->
                    li [] [ text <| String.fromInt id ++ ", " ++ animalType ++ ", " ++ String.fromFloat price ]
                )
                pets
        ]



-- ---------------------------
-- MAIN
-- ---------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    sendToken GetToken


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Get Pets"
                , body = [ view m ]
                }
        , subscriptions = subscriptions
        }

module Butler.App.GiveAway where

import Butler

import Butler.App
import Butler.AppSettings

giveAwayApp :: App
giveAwayApp =
    (defaultApp "giveAway" startGiveAway)
        { tags = fromList ["Utility"]
        , description = "A giveAway app"
        , settings =
            [ AppSetting "test-url" "" SettingURL
            , AppSetting "test-token" "" SettingToken
            ]
        }

data GiveAwayState = Clicked | Input Text

startGiveAway :: AppContext -> ProcessIO ()
startGiveAway ctx = do
    -- Setup state
    logInfo "GiveAway started!" []
    state <- newTVarIO Nothing
    let setState = atomically . writeTVar state . Just

    -- UI
    let mountUI :: HtmlT STM ()
        mountUI = with div_ [wid_ ctx.wid "w", class_ "flex flex-col"] do
            div_ "GiveAway"
            withTrigger_ "click" ctx.wid "trigger-name" button_ [] "Click me!"
            withTrigger_ "" ctx.wid "input-name" (input_ []) [type_ "text", placeholder_ "Type and enter...", name_ "value", class_ inputClass]
            div_ do
                lift (readTVar state) >>= \case
                    Just Clicked -> "Clicked!"
                    Just (Input txt) -> "Input: " <> toHtml txt
                    Nothing -> pure ()

    -- Handle events
    forever do
        atomically (readPipe ctx.pipe) >>= \case
            AppDisplay (UserJoined client) -> atomically $ sendHtml client mountUI
            AppTrigger ev -> do
                case ev.trigger of
                    "trigger-name" -> setState Clicked
                    "input-name" -> do
                        case ev.body ^? key "value" . _String of
                            Just txt -> setState (Input txt)
                            Nothing -> logError "Missing value" ["ev" .= ev]
                    "poker-result" ->
                        -- Demo how to close external app on result trigger event
                        case (ev.body ^? key "value" . _JSON, ev.body ^? key "wid" . _JSON) of
                            (Just v, Just wid) -> do
                                closeApp ctx.shared ev.client wid
                                logInfo "Poker result" ["v" .= (v :: Float)]
                            _ -> logError "Unknown result" ["ev" .= ev]
                    _ -> logError "Unknown trigger" ["ev" .= ev]
                sendsHtml ctx.shared.clients mountUI
            ev -> logError "Unknown ev" ["ev" .= ev]

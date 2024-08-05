module Main (main) where

import Butler qualified as B
import Butler.App.GiveAway
import Butler.Prelude

main :: IO ()
main = void $ B.runMain $ B.spawnInitProcess ".giveaway" $ runApp
  where
    runApp =
        B.serveApps (B.publicDisplayApp "GiveAway" Nothing) [giveAwayApp]

module Main where

import           Control.Apply
import           Control.Bind
import           Control.Monad.Eff
import           Control.Monad.Eff.Class
import           Control.Monad.Eff.Console
import           Data.Either
import           Data.Foreign
import           Data.Foreign.Class
import           Data.Maybe
import           Data.Maybe.Unsafe
import           Data.Nullable (toMaybe)
import           Global.Unsafe
import           Openspace.Engine
import           Openspace.Types
import           Openspace.Components.Greeter
import           Openspace.Components.Topic

import           Signal (runSignal, (~>), (<~))
import qualified Signal.Channel as C

import           Prelude
import           WebSocket

import qualified Thermite as T
import qualified Thermite.Action as T

import qualified React as R
import qualified React.DOM as R
import qualified React.DOM.Props as RP

import qualified DOM as DOM
import qualified DOM.HTML as DOM
import qualified DOM.HTML.Document as DOM
import qualified DOM.HTML.Types as DOM
import qualified DOM.HTML.Window as DOM
import qualified DOM.Node.Types as DOM

type FROST = C.Channel FROSTEvent

makeTopic :: FROST -> Topic -> R.ReactElement
makeTopic c t = topicF {channel: c, topic: t}

render :: T.Render _ AppState FROST Action
render dispatch s c _ = R.div' (makeTopic c <$> s.topics)

broadcastAction :: forall e. Socket -> Action -> Eff (ws :: WebSocket | e) Unit
broadcastAction s a = onOpen s $ send s (unsafeStringify (serialize a))

performAction :: Socket -> T.PerformAction _ AppState _ Action
performAction socket props Setup =
  do
    message <- T.async (onMessage socket)
    let mes =
        case readJSON message of
          Right a -> a
          Left err -> ShowError (show err)
    T.modifyState (evalAction mes)
    T.getState >>= liftEff <<< log <<< unsafeStringify
performAction socket _ a = do
    T.modifyState (evalAction a)
    liftEff (broadcastAction socket a)

spec :: Socket -> T.Spec _ AppState _ Action
spec socket = T.simpleSpec emptyState (performAction socket) render
              # T.componentWillMount Setup

main = do
  ws <- mkWebSocket "ws://frost.kritzcreek.me/socket/0"
  onOpen ws $ do
    send ws "{\"tag\":\"RequestState\",\"contents\":[]}"
  eventChannel <- C.channel (TopicClicked myTopic)
  runSignal $ C.subscribe eventChannel ~> log <<< show
  let component = T.createClass (spec ws)

  body >>= R.render (R.createFactory component eventChannel)

  where
  body :: forall eff. Eff (dom :: DOM.DOM | eff) DOM.Element
  body = do
    win <- DOM.window
    doc <- DOM.document win
    elm <- fromJust <$> toMaybe <$> DOM.body doc
    return $ DOM.htmlElementToElement elm

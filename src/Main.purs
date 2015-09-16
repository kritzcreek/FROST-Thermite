module Main where

import           Data.Foreign
import           Data.Foreign.Class (readJSON)
import qualified Data.List as L
import qualified Data.Map as M
import           Data.Maybe.Unsafe (fromJust)
import           Data.Nullable (toMaybe)

import           Global.Unsafe (unsafeStringify)

import           Openspace.Components.Greeter
import           Openspace.Components.Topic
import           Openspace.Engine

import           Signal (runSignal, (~>), (<~))
import qualified Signal.Channel as C
import           WebSocket

import Import
import qualified Import.DOM as DOM
import qualified Import.React as R
import qualified Import.Thermite as T
import qualified React.DOM.Props as RP

type FROST = C.Channel FROSTEvent

-- Component
-- UI Event
-- Net Event

makeTopic :: FROST -> Topic -> R.ReactElement
makeTopic c t = topicF {channel: c, topic: t}

assigned :: (Boolean -> Boolean) -> AppState -> Array Topic
assigned g s = Data.Array.filter (g <<< isAssigned) s.topics
  where isAssigned t = t `elem` (M.values s.timeslots)

render :: forall eff. T.Render eff AppState FROST Action
render dispatch s c _ = R.div' [
  R.h2' [R.text "Assigned Topics"]
  , R.div' (makeTopic c <$> assigned id s)
  , R.h2' [R.text "Unassigned Topics"]
  , R.div' (makeTopic c <$> assigned not s)
]

broadcastAction :: forall e. Socket -> Action -> Eff (ws :: WebSocket | e) Unit
broadcastAction s a = send s (unsafeStringify (serialize a))

performAction :: Socket -> T.PerformAction _ AppState FROST Action
performAction socket channel Setup = do
    message <- T.async (onMessage socket)
    let mes =
        case readJSON message of
          Right a -> a
          Left err -> ShowError (show err)
    T.modifyState (evalAction mes)
    liftEff $ runSignal (C.subscribe channel ~> handleEvent socket)
    -- T.getState >>= liftEff <<< log <<< unsafeStringify
performAction socket _ a = do
    -- T.modifyState (evalAction a)
    -- liftEff (broadcastAction socket a)
    return unit

handleEvent :: Socket -> FROSTEvent -> Eff _ Unit
handleEvent _ (UI e) = log (show e)
handleEvent s (Net e) = broadcastAction s e


spec :: Socket -> T.Spec _ AppState FROST Action
spec socket =
  T.simpleSpec emptyState (performAction socket) render
              # T.componentWillMount Setup

main = do
  ws <- mkWebSocket "ws://frost.kritzcreek.me/socket/0"
  onOpen ws $ do
    send ws "{\"tag\":\"RequestState\",\"contents\":[]}"
  eventChannel <- C.channel (UI Init)
  let component = T.createClass (spec ws)

  body >>= R.render (R.createFactory component eventChannel)

  where
  body :: forall eff. Eff (dom :: DOM.DOM | eff) DOM.Element
  body = do
    win <- DOM.window
    doc <- DOM.document win
    elm <- fromJust <$> toMaybe <$> DOM.body doc
    return $ DOM.htmlElementToElement elm

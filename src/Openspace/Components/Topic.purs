module Openspace.Components.Topic where

import Prelude
import Control.Apply
import Control.Bind
import Control.Monad.Eff
import Control.Monad.Eff.Class
import Control.Monad.Eff.Console

import Openspace.Types
import qualified Signal.Channel as C

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

type TopicProps = {
  topic   :: Topic,
  channel :: C.Channel FROSTEvent
}
data TopicAction = TopicClick

topicClass :: R.ReactClass TopicProps
topicClass = T.createClass topicSpec

topicF :: TopicProps -> R.ReactElement
topicF = R.createFactory topicClass

performTopic ::forall eff.
  T.PerformAction
  (console :: CONSOLE | eff)
  Unit
  TopicProps
  TopicAction
performTopic props TopicClick =
  liftEff $ C.send props.channel (TopicClicked props.topic)
performTopic _ _ = return unit

topicDesc (Topic t) = t.description

renderTopic :: T.Render _ _ _ _
renderTopic dispatch _ props children =
  R.div
    [RP.className "red", RP.onClick(\_ ->
      dispatch TopicClick
      )]
    [R.text (topicDesc props.topic)]

topicSpec :: T.Spec _ Unit TopicProps TopicAction
topicSpec = T.simpleSpec unit performTopic renderTopic

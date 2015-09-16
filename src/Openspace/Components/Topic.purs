module Openspace.Components.Topic where

import Import
import qualified Import.DOM as DOM
import qualified Import.React as R
import qualified Import.Thermite as T
import qualified React.DOM.Props as RP

import qualified Signal.Channel as C

type TopicProps = {
  topic   :: Topic,
  channel :: C.Channel FROSTEvent
}

data TopicAction = TopicClick

type TopicEff eff = (chan :: C.Chan | eff)

topicClass :: R.ReactClass TopicProps
topicClass = T.createClass topicSpec

topicF :: TopicProps -> R.ReactElement
topicF = R.createFactory topicClass

performTopic :: forall eff.
  T.PerformAction
  (TopicEff eff)
  Unit
  TopicProps
  TopicAction
performTopic props TopicClick =
  liftEff $ C.send props.channel (Net (DeleteTopic props.topic))

topicDesc :: Topic -> String
topicDesc (Topic t) = t.description

renderTopic :: forall eff. T.Render eff Unit TopicProps TopicAction
renderTopic dispatch _ props children =
  R.div
    [RP.className "red", RP.onClick(\_ ->
      dispatch TopicClick
      )]
    [R.text (topicDesc props.topic)]

topicSpec :: forall eff. T.Spec (TopicEff eff) Unit TopicProps TopicAction
topicSpec = T.simpleSpec unit performTopic renderTopic

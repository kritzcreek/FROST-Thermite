module Openspace.Components.Greeter where

import Prelude
import Control.Bind

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

type GreeterProps = Int

greeter = T.createClass greeterSpec

greeterF :: Int -> R.ReactElement
greeterF = R.createFactory greeter

performGreeter :: T.PerformAction _ _ GreeterProps _
performGreeter _ _ = return unit

renderGreeter :: T.Render _ _ GreeterProps _
renderGreeter _ props _ children = R.div' [R.text "Greetings", R.text (show (props + 1))]

greeterSpec = T.simpleSpec 1 performGreeter renderGreeter

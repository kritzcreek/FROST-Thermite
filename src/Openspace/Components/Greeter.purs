module Openspace.Components.Greeter where

import Import
import qualified Import.DOM as DOM
import qualified Import.React as R
import qualified Import.Thermite as T
import qualified React.DOM.Props as RP

type GreeterProps = Int

greeter = T.createClass greeterSpec

greeterF :: Int -> R.ReactElement
greeterF = R.createFactory greeter

performGreeter :: T.PerformAction _ _ GreeterProps _
performGreeter _ _ = return unit

renderGreeter :: T.Render _ _ GreeterProps _
renderGreeter _ props _ children = R.div' [R.text "Greetings", R.text (show (props + 1))]

greeterSpec = T.simpleSpec 1 performGreeter renderGreeter

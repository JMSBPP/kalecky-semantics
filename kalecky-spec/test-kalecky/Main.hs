module Main (main) where

import Test.Tasty (TestTree, defaultMain, testGroup)

import Kalecky.Types.NumericsSpec (scaleTests)
import Kalecky.Types.Units.UnitSpec (unitTests)

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests =
  testGroup "kalecky"
    [ scaleTests
    , unitTests
    ]

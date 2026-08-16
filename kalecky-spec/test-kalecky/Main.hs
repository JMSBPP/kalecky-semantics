module Main (main) where

import Test.Tasty (TestTree, defaultMain, testGroup)
import Test.Tasty.QuickCheck (testProperty, (===))

import Kalecky.Smoke (scaleFactor)

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests =
  testGroup "kalecky"
    [ testGroup "smoke"
        [ testProperty "scaleFactor b 0 == 1" $
            \(b :: Integer) -> scaleFactor b 0 === 1
        , testProperty "scaleFactor b 1 == b" $
            \(b :: Integer) -> scaleFactor b 1 === b
        ]
    ]

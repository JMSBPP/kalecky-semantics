module Kalecky.Types.Panel.PanelSpec (panelTests) where

import Data.List (nub, sort)
import Data.Maybe (isJust, isNothing)
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Groups.Region (Region (..))
import Kalecky.Types.Panel.Panel (cell, column, groups, panel, periods, row, window)

type P = Int

panelTests :: TestTree
panelTests =
  testGroup
    "Panel"
    [ testGroup
        "laws"
        [ testProperty "rectangular: every (group, period) cell of a built panel is Just" $
            \(ts :: [P]) ->
              let p = panel ts (\g t -> (fromEnum (g :: Region), t))
               in and [isJust (cell g t p) | g <- groups p, t <- periods p]
        , testProperty "periods are the de-duplicated input, in order" $
            \(ts :: [P]) -> periods (panel ts (\(_ :: Region) t -> t)) == nub ts
        , testProperty "row and cell agree" $
            \(ts :: [P]) ->
              let p = panel ts (\(g :: Region) t -> (g, t))
               in and [row g p == [(t, (g, t)) | t <- periods p] | g <- groups p]
        , testProperty "column reproduces the generating function" $
            \(ts :: [P]) (t :: P) ->
              let p = panel ts (\(g :: Region) t' -> (g, t'))
               in case column t p of
                    Nothing -> t `notElem` ts
                    Just f -> and [f g == (g, t) | g <- [minBound .. maxBound]]
        , testProperty "window succeeds iff the requested block is fully covered exactly once" $
            \(ts :: [P]) ->
              let complete = [(g, t, ()) | g <- [minBound .. maxBound :: Region], t <- nub ts]
               in isJust (window (nub ts) complete)
                    && (null ts || isNothing (window (nub ts) (drop 1 complete)))
        ]
    , testGroup
        "examples"
        [ testCase "a single data point is a one-cell panel per group" $ do
            let p = panel [7 :: P] (\(_ :: Region) _ -> "x")
            length [() | g <- groups p, t <- periods p, isJust (cell g t p)] @?= 2
            periods p @?= [7]
        , testCase "window ignores observations outside the requested periods" $ do
            let obs = [(Central, 1 :: P, 'a'), (Periphery, 1, 'b'), (Central, 9, 'z')]
            assertBool "block [1] covered" (isJust (window [1] obs))
            fmap (\p -> sort (periods p)) (window [1] obs) @?= Just [1]
        ]
    ]

-- | Denomination laws (approved 2026-08-15, relocated from NumericsSpec
-- to mirror the src tree — Denomination is money-side per Draft.plk's
-- @denomination_scale@).
module Kalecky.Types.Units.MoneyUnitSpec (moneyUnitTests) where

import Test.QuickCheck ((==>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Numerics (scaleFactor)
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.MoneyUnit
  ( Denomination (..)
  , denominationExponent
  , denominationScale
  )

moneyUnitTests :: TestTree
moneyUnitTests =
  testGroup
    "MoneyUnit"
    [ testGroup
        "laws"
        [ testProperty "denomination scales are exact powers of ten (0,3,6,9)" $
            \(d :: Denomination) ->
              scaleFactor (denominationScale d) == 10 ^ denominationExponent d
        , testProperty "denomination scales strictly monotone Raw<Thousand<Million<Billion" $
            \(d1 :: Denomination) (d2 :: Denomination) ->
              (d1 < d2) == (scaleFactor (denominationScale d1) < scaleFactor (denominationScale d2))
        , testProperty "coarser denominations are exact multiples of finer ones" $
            \(d1 :: Denomination) (d2 :: Denomination) ->
              d1 <= d2 ==>
                scaleFactor (denominationScale d2) `mod` scaleFactor (denominationScale d1) == 0
        ]
    , testGroup
        "examples"
        [ testCase "Million = 1_000_000" $
            scaleFactor (denominationScale Million) @?= 1_000_000
        ]
    ]

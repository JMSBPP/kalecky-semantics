-- | Denomination laws (approved 2026-08-15, relocated from NumericsSpec
-- to mirror the src tree — Denomination is money-side per Draft.plk's
-- @denomination_scale@).
module Kalecky.Types.Units.MoneyUnitSpec (moneyUnitTests) where

import Data.Maybe (isJust, isNothing)
import Numeric.Natural (Natural)
import Test.QuickCheck ((==>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Numerics (scaleFactor)
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Units.MoneyUnit
  ( Denomination (..)
  , denominationExponent
  , denominationScale
  , moneyUnit
  )
import Kalecky.Types.Units.Unit (qty, unitScale)

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
        , testProperty "COP: constructible iff qty·scale is a multiple of 50" $
            \(d :: Denomination) (k :: Natural) ->
              isJust (moneyUnit @COP d k)
                == ((k * scaleFactor (denominationScale d)) `mod` 50 == 0)
        , testProperty "COP: non-Raw denominations always constructible" $
            \(d :: Denomination) (k :: Natural) ->
              d /= Raw ==> isJust (moneyUnit @COP d k)
        , testProperty "USD: construction deferred — always Nothing" $
            \(d :: Denomination) (k :: Natural) ->
              isNothing (moneyUnit @USD d k)
        , testProperty "constructed money has qty k at the denomination's scale" $
            \(d :: Denomination) (k :: Natural) ->
              case moneyUnit @COP d k of
                Nothing -> True
                Just u -> qty u == k && unitScale u == denominationScale d
        ]
    , testGroup
        "examples"
        [ testCase "Million = 1_000_000" $
            scaleFactor (denominationScale Million) @?= 1_000_000
        , testCase "20000 COP Raw constructs (the CASO PRUEBA minimum wage)" $
            assertBool "expected Just" (isJust (moneyUnit @COP Raw 20000))
        , testCase "20025 COP Raw rejected (not a multiple of 50)" $
            assertBool "expected Nothing" (isNothing (moneyUnit @COP Raw 20025))
        ]
    ]

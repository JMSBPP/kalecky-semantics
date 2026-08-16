-- | Co-designed ResponseMultiplier & Indexation laws (approved 2026-08-16).
module Kalecky.Operators.RefinementSpec (refinementTests) where

import Test.QuickCheck (Arbitrary (..))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Effect (Effect, applyEffect, effect)
import Kalecky.Operators.GrowthRate (GrowthRate, growthRate, rate)
import Kalecky.Operators.Indexation (Indexation, applyIndexation, indexation, indexationDegree)
import Kalecky.Operators.ResponseMultiplier (ResponseMultiplier, applyResponse, responseMultiplier, responseValue)

data W  -- wage growth (responder / target)
data G  -- gap (perturband)
data P  -- price level (reference)

refinementTests :: TestTree
refinementTests =
  testGroup
    "Refinements"
    [ testGroup
        "laws"
        [ testProperty "no redundant scalar: responseValue . responseMultiplier == id" $
            \(c :: Rational) -> responseValue (responseMultiplier c :: ResponseMultiplierWG) == c
        , testProperty "applyResponse == applyEffect of the wrapped coefficient" $
            \(c :: Rational) (x :: Rational) ->
              applyResponse (responseMultiplier c :: ResponseMultiplierWG) x
                == applyEffect (effect c :: EffectWG) x
        , testProperty "applyIndexation i r == indexationDegree i * rate r" $
            \(d :: Rational) (r :: Rational) ->
              applyIndexation (indexation d :: IndexationWP) (growthRate r :: RateP)
                == d * r
        , testProperty "full indexation (degree 1) transmits the reference rate unchanged" $
            \(r :: Rational) ->
              applyIndexation (indexation 1 :: IndexationWP) (growthRate r :: RateP) == r
        ]
    , testGroup
        "examples"
        [ testCase "wage-equation term shape: RM 3/10 on a +2000/3600 gap evaluation" $
            applyResponse (responseMultiplier (3 / 10) :: ResponseMultiplierWG) (2000 / 3600)
              @?= 1 / 6
        , testCase "indexation 1/2 of 5% inflation contributes exactly 1/40" $
            applyIndexation (indexation (1 / 2) :: IndexationWP) (growthRate (1 / 20) :: RateP)
              @?= 1 / 40
        ]
    ]

type ResponseMultiplierWG = ResponseMultiplier W G
type EffectWG = Effect W G
type IndexationWP = Indexation W P
type RateP = GrowthRate P

-- | Co-designed Effect laws and example (approved 2026-08-16).
module Kalecky.Operators.EffectSpec (effectTests) where

import Test.QuickCheck (Arbitrary (..))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Operators.Effect (Effect, applyEffect, effect, effectValue)

data R
data P

instance Arbitrary (Effect R P) where
  arbitrary = effect <$> arbitrary

effectTests :: TestTree
effectTests =
  testGroup
    "Effect"
    [ testGroup
        "laws"
        [ testProperty "roundtrip: effectValue (effect r) == r" $
            \(r :: Rational) -> effectValue (effect r :: Effect R P) == r
        , testProperty "linearity: applyEffect e (a + b) == applyEffect e a + applyEffect e b" $
            \(e :: Effect R P) (a :: Rational) (b :: Rational) ->
              applyEffect e (a + b) == applyEffect e a + applyEffect e b
        , testProperty "zero perturbation, zero response: applyEffect e 0 == 0" $
            \(e :: Effect R P) -> applyEffect e 0 == 0
        ]
    , testGroup
        "examples"
        [ testCase "coefficient 3/10 applied to a +1/2 perturbation responds +3/20" $
            applyEffect (effect (3 / 10) :: Effect R P) (1 / 2) @?= 3 / 20
        ]
    ]

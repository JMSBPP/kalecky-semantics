module Kalecky.Types.Stocks.StateVectorSpec (stateVectorTests) where

import Data.Maybe (fromJust, isJust, isNothing)
import Numeric.Natural (Natural)
import Test.QuickCheck ((==>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (assertBool, testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Currency (Currency (..))
import Kalecky.Types.Groups.Capital (CapitalGroup (..))
import Kalecky.Types.Groups.Population (PopulationGroup)
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Stocks.StateVector (StateVector, component, share, stateVector, total)
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.MoneyUnit (Denomination (..), MoneyBasis, moneyUnit)
import Kalecky.Types.Units.Unit (Unit, unit, value)

pop :: [Natural] -> (PopulationGroup -> Unit WorkerBasis)
pop ks g = unit Worker (ks !! fromEnum g)

stateVectorTests :: TestTree
stateVectorTests =
  testGroup
    "StateVector"
    [ testGroup
        "laws"
        [ testProperty "Just iff the components sum exactly to the total (and total > 0)" $
            \(a :: Natural) (b :: Natural) (c :: Natural) (d :: Natural) (e :: Natural) (t :: Natural) ->
              let ks = [a, b, c, d, e]
               in isJust (stateVector (pop ks) (unit Worker t))
                    == (sum ks == t && t > 0)
        , testProperty "shares sum to exactly 1" $
            \(a :: Natural) (b :: Natural) (c :: Natural) (d :: Natural) (e :: Natural) ->
              let ks = [a, b, c, d, e]; t = sum ks
               in t > 0 ==>
                    let v = fromJust (stateVector (pop ks) (unit Worker t))
                     in sum [share g v | g <- [minBound .. maxBound]] == 1
        , testProperty "components and total round-trip" $
            \(a :: Natural) (b :: Natural) (c :: Natural) (d :: Natural) (e :: Natural) ->
              let ks = [a, b, c, d, e]; t = sum ks
               in t > 0 ==>
                    let v = fromJust (stateVector (pop ks) (unit Worker t))
                     in value (total v) == t && [value (component g v) | g <- [minBound .. maxBound]] == ks
        ]
    , testGroup
        "examples"
        [ testCase "N reconciles: 5 groups summing to the observed total" $
            assertBool "expected Just" (isJust (stateVector (pop [10, 20, 30, 40, 50]) (unit Worker 150)))
        , testCase "N off by one worker does not reconcile" $
            assertBool "expected Nothing" (isNothing (stateVector (pop [10, 20, 30, 40, 50]) (unit Worker 151)))
        , testCase "K = K_F + K_K + K_MC in Thousand COP reconciles against a Raw-COP total" $ do
            let k g = fromJust (moneyUnit @COP Thousand ([100, 250, 50] !! fromEnum (g :: CapitalGroup)))
                tot = fromJust (moneyUnit @COP Raw 400000)
                v = fromJust (stateVector k tot) :: StateVector CapitalGroup (MoneyBasis COP)
            share KK v @?= 250 / 400
        ]
    ]

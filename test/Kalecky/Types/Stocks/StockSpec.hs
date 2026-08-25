module Kalecky.Types.Stocks.StockSpec (stockTests) where

import Data.Maybe (fromJust, isJust, isNothing)
import Numeric.Natural (Natural)
import Test.QuickCheck (Arbitrary (..), (==>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.QuickCheck (testProperty)

import Kalecky.Types.Groups.Region (Region (..))
import Kalecky.Types.NumericsSpec ()
import Kalecky.Types.Panel.Panel (cell)
import Kalecky.Types.Panel.Period (Period, next, period)
import Kalecky.Types.Stocks.StateVector (StateVector, component, stateVector, total)
import Kalecky.Types.Stocks.Stock (Role (..), Stock, at, point, series, stock, toPanel, totals)
import Kalecky.Types.Units.LaborUnit (WorkerBasis (..))
import Kalecky.Types.Units.TimeUnit (TimeBasis (..))
import Kalecky.Types.Units.Unit (unit, value)

regional :: Natural -> Natural -> StateVector Region WorkerBasis
regional c p =
  fromJust (stateVector (\r -> unit Worker (if r == Central then c else p)) (unit Worker (c + p)))

instance Arbitrary (StateVector Region WorkerBasis) where
  arbitrary = regional <$> ((+ 1) <$> arbitrary) <*> ((+ 1) <$> arbitrary)

contiguous :: TimeBasis -> Natural -> [StateVector Region WorkerBasis] -> [(Period, StateVector Region WorkerBasis)]
contiguous g start vs = zip (iterate next (period g start)) vs

stockTests :: TestTree
stockTests =
  testGroup
    "Stock"
    [ testGroup
        "laws"
        [ testProperty "contiguous same-granularity periods build, in any order" $
            \(g :: TimeBasis) (start :: Natural) (vs :: [StateVector Region WorkerBasis]) ->
              not (null vs) ==>
                isJust (stock (reverse (contiguous g start vs)) :: Maybe (Stock Base Region WorkerBasis))
        , testProperty "a gap in the periods is rejected" $
            \(g :: TimeBasis) (start :: Natural) (v :: StateVector Region WorkerBasis) ->
              isNothing (stock [(period g start, v), (period g (start + 2), v)] :: Maybe (Stock Base Region WorkerBasis))
        , testProperty "a repeated period is rejected" $
            \(g :: TimeBasis) (start :: Natural) (v :: StateVector Region WorkerBasis) ->
              isNothing (stock [(period g start, v), (period g start, v)] :: Maybe (Stock Base Region WorkerBasis))
        , testProperty "mixed granularities are rejected" $
            \(v :: StateVector Region WorkerBasis) ->
              isNothing (stock [(period Month 1, v), (period Hour 2, v)] :: Maybe (Stock Base Region WorkerBasis))
        , testProperty "every at-column is the state vector that was put in" $
            \(g :: TimeBasis) (start :: Natural) (vs :: [StateVector Region WorkerBasis]) ->
              not (null vs) ==>
                let ps = contiguous g start vs
                    s = fromJust (stock ps) :: Stock Level Region WorkerBasis
                 in and [at p s == Just v | (p, v) <- ps]
        , testProperty "totals and series are consistent with the state vectors" $
            \(g :: TimeBasis) (start :: Natural) (vs :: [StateVector Region WorkerBasis]) ->
              not (null vs) ==>
                let ps = contiguous g start vs
                    s = fromJust (stock ps) :: Stock Level Region WorkerBasis
                 in map (fmap value) (totals s) == [(p, value (total v)) | (p, v) <- ps]
                      && map (fmap value) (series Central s)
                        == [(p, value (component Central v)) | (p, v) <- ps]
        ]
    , testGroup
        "examples"
        [ testCase "point is a one-period stock" $ do
            let s = point (period Month 5) (regional 3 4) :: Stock Base Region WorkerBasis
            map fst (totals s) @?= [period Month 5]
        , testCase "toPanel exposes the component cells" $ do
            let s = fromJust (stock (contiguous Month 1 [regional 3 4, regional 5 6])) :: Stock Base Region WorkerBasis
            fmap value (cell Periphery (period Month 2) (toPanel s)) @?= Just 6
        ]
    ]

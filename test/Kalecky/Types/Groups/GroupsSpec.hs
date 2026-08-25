module Kalecky.Types.Groups.GroupsSpec (groupsTests) where

import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))

import Kalecky.Types.Groups.Capital (CapitalGroup (..))
import Kalecky.Types.Groups.Education (EducationGroup (..))
import Kalecky.Types.Groups.Labor (LaborGroup (..))
import Kalecky.Types.Groups.Population (PopulationGroup (..))
import Kalecky.Types.Groups.Region (Region (..))

groupsTests :: TestTree
groupsTests =
  testGroup
    "Groups"
    [ testCase "population partition is exactly {NK, NF, NLI, NL, NML}" $
        [minBound .. maxBound] @?= [NK, NF, NLI, NL, NML]
    , testCase "capital partition is exactly {KF, KK, KMC}" $
        [minBound .. maxBound] @?= [KF, KK, KMC]
    , testCase "labor partition is exactly {LI, LF, LML}" $
        [minBound .. maxBound] @?= [LI, LF, LML]
    , testCase "education partition is exactly {EPublic, EPrivate}" $
        [minBound .. maxBound] @?= [EPublic, EPrivate]
    , testCase "regions are exactly {Central, Periphery}" $
        [minBound .. maxBound] @?= [Central, Periphery]
    ]

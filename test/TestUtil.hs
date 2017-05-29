{-# OPTIONS_GHC -fno-warn-orphans #-}

module TestUtil
    ( module X
    , unsafefromByteString
    ) where

import Test.Hspec            as X
import Test.Hspec.QuickCheck as X
import Test.QuickCheck       as X hiding (generate)

import qualified Data.ByteString.Char8 as BS
import qualified Data.HashMap.Strict   as H
import qualified Data.Maybe            as Maybe
import qualified Data.Time.Clock       as Time
import qualified Data.Time.Calendar    as Time

import Data.Blockchain.Core.Crypto
-- import Data.Blockchain.Crypto.HashTree
import Data.Blockchain.Core.Types

-- Used in some tests to filter generated difficulties that would be too hard to solve.
-- maxDifficulty :: Difficulty
-- maxDifficulty = Difficulty $ unsafefromByteString $ BS.append "0000" $ BS.replicate 60 'f'

unsafefromByteString :: BS.ByteString -> Hash a
unsafefromByteString = Maybe.fromMaybe (error "Invalid hash string") . fromByteString

-- Instances -------------------------------------------------------------------------------------------------

-- Blockchain types

instance Arbitrary BlockchainConfig where
    arbitrary = BlockchainConfig
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> (H.fromList <$> arbitrary)

-- instance Arbitrary Block where
--     arbitrary = makeBlock
--       <$> (hash <$> arbitrary)
--       <*> arbitrary
--       <*> arbitrary
--       <*> arbitrary
--       <*> return [] -- TODO: arbitrary Transaction

-- instance Arbitrary BlockHeader where
--     arbitrary = BlockHeader
--         <$> arbitrary
--         <*> arbitrary
--         <*> return (hashTreeRoot []) -- TODO: arbitrary Transaction
--         <*> arbitrary
--         <*> arbitrary
--         <*> arbitrary

instance Arbitrary Difficulty where
    arbitrary = Difficulty <$> arbitrary

-- Crypto Types

instance Arbitrary (Hash a) where
    arbitrary = unsafefromByteString . BS.pack <$> vectorOf 64 hexChar
      where
        hexChar = elements $ ['0' .. '9'] ++ ['a' .. 'f']

-- Other Types

instance Arbitrary BS.ByteString where
    arbitrary = BS.pack <$> arbitrary

instance Arbitrary Time.UTCTime where
    arbitrary = Time.UTCTime <$> dayDen <*> dayTimeGen
      where
        -- The Modified Julian Day is a standard count of days, with zero being the day 1858-11-17.
        dayDen    = Time.ModifiedJulianDay <$> elements [0 .. 60000]
        -- The time from midnight, 0 <= t < 86401s (because of leap-seconds)
        dayTimeGen = Time.secondsToDiffTime <$> elements [0 .. 86400]

module Main where

import Control.Monad

putList :: Show a => [a] -> IO ()
putList = mapM_ $ putStrLn . show

primes :: [Integer]
primes = p' [] [2..]

p' :: [Integer] -> [Integer] -> [Integer]
p' ps (x:xs) = 
    case (isPrime ps x) of
      True  -> (x : (p' (ps ++ [x]) xs))
      False -> p' ps xs
  where 
    isPrime ps x =
      not $ any (\p -> x `mod` p == 0) ps

main :: IO ()
main = do
  putList $ take 1000 primes
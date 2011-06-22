module Scheme where

import Control.Monad
import Control.Monad.Error

import Text.ParserCombinators.Parsec (parse)
import Parser (readLisp, parseExpr, parseProgram)
import Scope (Scope, nullScope)
import Value


replLisp :: Scope Value -> String -> IO String
replLisp s input = do
  let result = readLisp input
  -- result <- runErrorT (evalLisp s input)
  -- putValue s "_" $ either (String) (id) result -- make "_" the value of the prev expr
  return $ either (id) (show) result

evalExpr :: String -> IO String
evalExpr input = do 
  s <- nullScope
  replLisp s input
  
buildREPL :: [String] -> IO(String -> IO ())
buildREPL args= do
    s <- nullScope
    return (\input -> replLisp s input >>= putStrLn)
  

module Scheme where

import Control.Monad
import Control.Monad.Error

import Text.ParserCombinators.Parsec (parse)
import Parser (readLisp, parseExpr, parseProgram)
import Scope (Scope, nullScope)
import Value
import Eval
import Error


replLisp :: Scope Value -> String -> IO String
replLisp s input = do
  result <- runErrorT (do
      ast <- liftThrows $ readLisp input
      evalLast s ast
    )
  -- putValue s "_" $ either (String) (id) result -- make "_" the value of the prev expr
  return $ either (id) (show) result

evalExpr :: String -> IO String
evalExpr input = do 
  s <- topScope
  replLisp s input
  
buildREPL :: IO(String -> IO ())
buildREPL = do
    s <- topScope
    return (\input -> replLisp s input >>= putStrLn)
  

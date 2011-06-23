module Main where
import System.Environment
import System.Console.SimpleLineEditor as SLE
import Control.Monad
import LLVM.Core
import LLVM.ExecutionEngine
import IO hiding (try)
import Scheme

flushStr :: String -> IO ()
flushStr str = putStr str >> hFlush stdout

readPrompt :: String -> IO String
readPrompt prompt = 
  maybe "exit" id `liftM` getLineEdited prompt

until_ :: Monad m => (a -> Bool) -> m a -> (a -> m ()) -> m ()
until_ pred prompt action = do 
  result <- prompt
  if pred result 
     then return ()
     else action result >> until_ pred prompt action
     
main :: IO ()
main = do 
  initializeNativeTarget
  repl <- buildREPL
  SLE.initialise
  until_ (== "exit") (readPrompt "Lisp: -> ") (repl)
  SLE.restore
  

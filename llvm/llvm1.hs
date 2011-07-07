module Main where

import LLVM.Core
import LLVM.ExecutionEngine
import Data.Int
import Data.Word
import Foreign.Marshal.Array

ps a = putStrLn $ show a

mSum :: CodeGenModule (Function (Int32 -> Ptr Int32 -> IO Int32))
mSum = 
  createFunction ExternalLinkage $ \ s ptr_x -> do
    x <- load ptr_x
    s' <- add s x
    ret s'

main :: IO ()
main = do
    initializeNativeTarget
    m <- newModule
    ps m
    ps $ valueOf (0::Int32)
    llvmSum <- simpleFunction mSum
    r <- withArray [3,4,5] $ \arr -> do llvmSum 2 arr
    ps r
    putStrLn "Done"
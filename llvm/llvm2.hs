module Main where

import LLVM.Core
import LLVM.ExecutionEngine
import LLVM.Util.Loop
import Data.Int
import Data.Word
import Foreign.Marshal.Array

ps a = putStrLn $ show a

getIndex ptr offset = getElementPtr ptr (offset, ())


mSum :: CodeGenModule (Function (Int32 -> Ptr Int32 -> IO Int32))
mSum = do
  fSqr <- createFunction InternalLinkage $ \ a b -> do
    p <- mul b b
    r <- add a p
    ret r
  let _ = fSqr :: Function (Int32 -> Int32 -> IO Int32)
  
  sum <- createFunction ExternalLinkage $ \ l ptr_x -> do
    r <- forLoop (valueOf 0) l (valueOf (0::Int32)) $ \i sum -> do
      xi <- getIndex ptr_x i
      x <- load xi
      call fSqr sum x
    ret r
  let _ = sum :: (Function (Int32 -> Ptr Int32 -> IO Int32))
  return sum

main :: IO ()
main = do
    initializeNativeTarget
    m <- newModule
    ps m
    ps $ valueOf (0::Int32)
    llvmSum <- simpleFunction mSum
    r <- withArrayLen [3..8] $ \l arr -> do llvmSum (fromIntegral l) arr
    ps r
    putStrLn "Done"
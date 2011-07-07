module Main where

import LLVM.Core
import LLVM.ExecutionEngine
import LLVM.Util.Loop
import Data.Int
import Data.Word
import Foreign.Ptr
import Foreign.Marshal.Array

ps a = putStrLn $ show a

foo :: Int32 -> Int32 -> Int32
foo a b = a*a + b*b

foreign import ccall "wrapper"
  mkCB :: (Int32 -> Int32 -> Int32) -> IO (FunPtr (Int32 -> Int32 -> Int32))

getIndex ptr offset = getElementPtr ptr (offset, ())

mSum :: CodeGenModule (Function (Int32 -> Int32 -> Function (Int32 -> Int32-> Int32) ->IO Int32))
mSum = 
  createFunction ExternalLinkage $ \ a b _ -> do
    r <- add a b
    ret r

main :: IO ()
main = do
    initializeNativeTarget
    m <- newModule
    fp <- mkCB foo
    ps m
    ps $ valueOf (0::Int32)
    -- llvmSum <- simpleFunction mSum
    -- r <- withArrayLen [3..8] $ \l arr -> do llvmSum (fromIntegral l) arr $ ((castFunPtrToPtr fp) :: Ptr Word32)
    -- ps r
    putStrLn "Done"
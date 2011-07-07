module Main where

import LLVM.Core
import LLVM.ExecutionEngine
import LLVM.Util.Loop
import Data.Int
import Data.Word
import Foreign.Ptr
import Foreign.Marshal.Array
import Control.Monad

ps a = putStrLn $ show a

type Acc = Int32 -> Int32 -> IO Int32
type Sig = Int32 -> Ptr Int32 -> Ptr Acc-> IO Int32


foreign import ccall "dynamic"
  runLLVM :: FunPtr Sig -> Sig

getIndex ptr offset = getElementPtr ptr (offset, ())



fSqr :: CodeGenModule (Function Acc)
fSqr = createNamedFunction ExternalLinkage "sqr" $ \ a b -> do
    p <- mul b b
    r <- add a p
    ret r

mSum :: CodeGenModule (Function Sig)
mSum = createNamedFunction ExternalLinkage "sum" $ \l ptr_x fn ->  do
    r <- forLoop (valueOf 0) l (valueOf (0::Int32)) $ \i sum -> do
      xi <- getIndex ptr_x i
      x <- load xi
      call fn sum x
    ret r
  
fns :: CodeGenModule ()
fns = do
  fSqr
  mSum
  return ()

buildFunction :: Module 
                 -> CodeGenModule a 
                 -> IO Sig
buildFunction m code=  do
  Just fun <-liftM (castModuleValue  <=< lookup "sum") $ getModuleValues m
  funptr <- (runEngineAccess . getPointerToFunction) fun
  return $ runLLVM funptr

main :: IO ()
main = do
    initializeNativeTarget
    m <- newModule
    defineModule m fns
    putStr "JIT Compilation ... "
    llvmSum <- buildFunction m fns
    putStrLn "complete."
    vs <- getModuleValues m
    ps vs
    Just fun <-liftM (castModuleValue  <=< lookup "sqr") $ getModuleValues m
    let _ = fun :: Function Acc
    fun' <- (runEngineAccess . getPointerToFunction) fun
    r <- withArrayLen [3..12] $ \l arr -> do llvmSum (fromIntegral l) arr $ castFunPtrToPtr fun'
    ps r
    putStrLn "Done"
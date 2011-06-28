module Compile where

import Value as V
import Error
import Data.Int
import Data.Word
import Foreign.Ptr
import Foreign.Marshal.Array
import Control.Monad.Error
import LLVM.Core as L
import LLVM.ExecutionEngine

compile :: [V.Value] -> V.Value -> IOThrowsError([Integer]->IO Integer)
compile params body = do
  ps  <- liftThrows $ map_params params
  cgf <- liftThrows $ generateCode ps body
  liftIO $ (doJIT >=> buildFunction) cgf
  
  
map_params :: [V.Value] -> ThrowsError[(String,Word32)]
map_params xs = 
  mp 0 xs
  where
    mp _ [] = return []
    mp n ((Var s):xs) = liftM2 (:) (return (s,n)) (mp (n+1) xs)
    mp _ (e:_) = throwError $ "Invalid Argument in parameter list: " ++ show e
    
getIndex ptr offset = getElementPtr ptr (offset, ())

generateCode :: [(String,Word32)] -> V.Value -> ThrowsError (CodeGenModule (Function (Ptr Int32 -> IO Int32)))
generateCode params body = return $ createFunction ExternalLinkage $ \xs -> do
  value <- generateBodyCode params xs body
  ret value  


generateBodyCode params args (Var s) = do
  let Just i = lookup s params
  vi <- getIndex args i
  load vi  
generateBodyCode _ _ (Number n) = return $ valueOf (fromIntegral n)
generateBodyCode params args (List (Var "+":a:b:[])) = do
  va <- generateBodyCode params args a
  vb <- generateBodyCode params args b
  add va vb


doJIT :: CodeGenModule (Function(Ptr Int32 -> IO Int32)) -> IO (Function (Ptr Int32 -> IO Int32))
doJIT cgm = do
  createModule cgm

foreign import ccall "dynamic"
  runLLVM :: FunPtr (Ptr Int32-> IO Int32) -> (Ptr Int32-> IO Int32)

buildFunction :: Function (Ptr Int32 -> IO Int32) -> IO ([Integer] -> IO Integer)
buildFunction fun =  do
  funptr <- (runEngineAccess . getPointerToFunction) fun
  return $ \xs -> withArray (map fromIntegral xs) $ \array -> fromIntegral `liftM` runLLVM funptr array

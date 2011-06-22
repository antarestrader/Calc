module Scope where

import Data.IORef

type ScopeImpl a = IORef [(String,IORef a)]

data Scope a = Scope (ScopeImpl a) (Scope a)
             | Empty

nullScope:: IO(Scope a)
nullScope = do
  ref <- newIORef([]) 
  return $ Scope ref Empty

buildScope :: [(String,a)] -> IO(Scope a)
buildScope input = do
  s <- nullScope
  addToScope s input
  return s
  
deriveScope :: Scope a -> [(String,a)] -> IO(Scope a)
deriveScope p input = do
  ref <- newIORef([])
  s <- return $ Scope ref p
  addToScope s input
  return s
 
putValue :: Scope a -> String-> a -> IO()
putValue s var val = do
  ref <- getReference var s
  case ref of
    Just r -> writeIORef r val      -- it exists clobber the old value
    Nothing -> writeValue s var val -- can't find it put a new copy in this scope

writeValue :: Scope a -> String-> a -> IO()
writeValue (Scope refenv _) var val = do
  env  <- readIORef refenv
  val' <- newIORef val
  writeIORef refenv ((var,val'):env)

getReference :: String -> Scope a -> IO(Maybe (IORef a))
getReference _ Empty = return Nothing
getReference var (Scope s p) = do
  env <- readIORef s 
  case (lookup var env) of
    Nothing -> getReference var p
    ref -> return ref 

getValue ::  Scope a-> String ->  IO(Maybe a)
getValue Empty _ = return Nothing
getValue s var = do
  ref <- getReference var s 
  case (ref) of
    Nothing -> return Nothing
    Just ref' -> do
      val <- readIORef ref'
      return $ Just val
      
hasValue :: Scope a -> String -> IO(Bool)
hasValue s var = do
  ref <-getReference var s
  case ref of
    Nothing -> return False
    Just _ -> return True
    
dumpScope :: Scope a -> IO[(String,a)]
dumpScope (Scope s p) = do
  env <- readIORef s
  mapM dmp env
  
  
dmp :: (String,IORef a) -> IO(String,a)
dmp (var,refval) = do
  val <- readIORef refval
  return (var,val)
    
      
addToScope :: Scope a -> [(String, a)] -> IO()
addToScope s input = do
  mapM (\x -> writeValue s (fst x) (snd x)) input
  return ()




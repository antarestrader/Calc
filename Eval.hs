module Eval where

import Control.Monad.Error
import Value
import Error
import Scope

topScope :: IO(Scope Value)
topScope = buildScope [("+", Function (foldl (+) 0))]

eval :: Scope Value -> Value -> IOThrowsError Value
eval s (List (f:vs)) = do
  f' <- eval s f 
  apply s f' vs
eval s (Var val) = (liftIO $ getValue s val) >>= maybe (throwError $ "Value not in scope: " ++ val) (return)
eval _ val = return val

evalLast _ [] = throwError "No Input Found"
evalLast s [v] = eval s v
evalLast s (v:vs) = eval s v >> evalLast s vs

apply :: Scope Value -> Value -> [Value] -> IOThrowsError Value
apply s (Function f) vs = do
  vs' <- mapM (eval s) vs
  is  <- mapM extractInteger vs'
  return $ Number (f is)
apply _ f _ = throwError $ "Not a Function: " ++ show f
  
extractInteger :: Value -> IOThrowsError Integer
extractInteger (Number n) = return n
extractInteger x = throwError $ "Not an Integer: " ++ show x
  
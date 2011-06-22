module Error where

import Control.Monad.Error

type ThrowsError = Either String

type IOThrowsError = ErrorT String IO

liftThrows :: ThrowsError a -> IOThrowsError a
liftThrows (Left err) = throwError err
liftThrows (Right val) = return val
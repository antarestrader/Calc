module Value where


data Value = Var String
  | Number Integer
  | List [Value]
  | Function ([Integer] -> IO Integer)
  
instance Show Value where
  showsPrec _ (Var s) = showString s
  showsPrec _ (Number n) = shows n
  showsPrec _ (List []) = showString "()" 
  showsPrec p (List [x]) = showParen (p == 0) $ shows x
  showsPrec p (List (x:xs)) = showParen (p == 0) $ shows x . showString " " . showsPrec 1 (List xs)
  showsPrec p (Function _) = showString "<function>"
module Parser where

import Control.Monad
import Control.Monad.Error
import Text.ParserCombinators.Parsec hiding (spaces)
import qualified Text.ParserCombinators.Parsec.Token as P
import Text.ParserCombinators.Parsec.Language (haskellDef)

import Error
import Value

lexer = P.makeTokenParser haskellDef
number = P.natural lexer
parens = P.parens lexer
lexeme = P.lexeme lexer

symbol :: Parser Char
symbol = oneOf "!#$%&|*+-/:<=>?@^_~"

spaces :: Parser ()
spaces = skipMany1 space


parseVar :: Parser Value
parseVar = do first <- letter <|> symbol
              rest <- many (letter <|> digit <|> symbol)
              return $ Var (first:rest)

parseNumber :: Parser Value
parseNumber = do
  n <- number
  return $ Number n
    
parseList :: Parser Value
parseList = liftM List (parens (many parseExpr))

parseExpr :: Parser Value
parseExpr = parseList
         <|> lexeme parseVar
         <|> parseNumber

parseProgram :: Parser [Value]
parseProgram = many parseExpr

readLisp :: String -> ThrowsError [Value]
readLisp input = case parse parseProgram "(expression)" input of
  Left err -> throwError $ "Parse Error:\n" ++ show err
  Right vals -> return vals
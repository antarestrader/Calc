#Calc#

A simplified lisp-like calculator written in haskell to show how to use LLVM JIT
compilation. It was written as a way to teach myself the workings of the llvm
haskell bindings.

##Getting Started##

It should be noted before begingin that this program is not useful but is
instead and example -- a toy.  But toy is no fun unless you know how to use it.

###Installation##

You will need:

* [The Glorious Glasgow Haskell Compilation System, version 7.0.4][1].
  Version 7.0.3 *may* also work but the author has not tried it.
* [LLVM Version 2.9][2]. Version 2.8 *may* work but the author has not tried it. 
* The Haskell llvm bindings.  The easiest way to get these is to `cabal install
  llvm`.  However, some recent version of the llvm bindings were not compatible
  with LLVM 2.9.  In that case clone the [github repository][https://github.com/bos/llvm]
  and do a `cabal install` from within that directory
  
Once all the dependencies are installed, `ghc -o calc Main.hs` will compile
the `calc` program.

###Runing `calc`###

The program uses the standard Lisp syntax for writing equations.  So instead of
`2 + 3 * 5` you would instead write `(* (+ 2 3) 5)`.  Equations written at the
prompt will be evaluated by an interperter.

calc will compile functions written with the `define` syntax.  Note: **Only** 
functions can be defined. Ex:

    (define (foo x y) (+ (+ x x) (+ y y) 10)
    
This will define a function called `foo` which takes two arguments and
calculates the value of the equation x+x + y+y + 10.

The prompt is readline enabled.  You may leav the program by typing "exit"
at the prompt.

###Limitations###

In order to keep this program as simpe as possible several limitations are
imposed that are not present in a typical Lisp:

* Only Integers are allowed
* At this time only `(+)` is defined as an opperator
* The check that the number of arguments matched the numner of parameters is
  elided.
* The `define` is the only syntax defined and it only works in the form above.

## The Dime Tour##

### Main.hs ###

We begin with some imports and utility functions:

* flushStr is cruft from a time before readline support
* readPrompt takes a string -- the prompt line, get a line of input from the
  terminal, and returns that string.
* until_ is the semi-infinate loop that runs the REPL

In Main, we begin by initializing the JIT enginge from LLVM.ExecutionEngine.
Then we initialize the Read Eval Print Loop (repl) from Scheme.hs, and setup
ReadLine support as found in System.Console.SimpleLineEditor.

We then repeatedly read a prompt and pass the resulting line to repl displaying
the result of each evaluation.

The string "exit" break the loop in until and we clean up our terminal with
`SLE.restore` before exiting.

### Scheme.hs ###

This file take the various opperations like parsing, evaluation, and error
handleing and glues them together.

The replLisp function is what makes this happen.  It takes the current active
scope and a string to process and returns the result in the IO monad.  The 
Evaluator runs within an error transformer layered over the IO monad.
This structure is defined throughout as IOThrowsError from Error.hs. The
replLisp function therefore wraps is primary work in a call to runErrorT.

First it uses readLisp form the Parser to build an Abstract Syntax Tree (ast)
of `Value`s.  It passes this ast to evalLast which actually runs each statement
present in the ast but returns the result only of the last.  See Eval.hs for an
implimentation.

The result value is an Either in the standard configuration with errors as 
strings on the left or a succesful result value on the right. The final line
merges these potential outcomes into a string for display.

The buildREPL funciton first creates a new topscope from Eval.hs then produces
a function to use that scope with replLisp to run a Read Eval Print Loop.

The evalExpr function can be used from GHCi for running strings directly.  It
will create a fresh top binding each time it is called however so it is not 
very useful for testing `define` statements.

### Parser.hs ##

The workings of a parsec parser are beyond the scope of this example.  This
File impliments a very simple parser which turn strings into Abstract Syntax
Trees (asts).  The Grammar builds from small to large as you read down the page
with parseProgram being the complete parser.

readLisp arranges to take a String and adds the necessary extra functionality
needed to run a parsec parser and format errors.

### Scope.hs ### 

The working of this file are also beyond the scope of this example.  It is
borrowed from a much more functionally complete Scheme interpreter.  The 
simple version is that this is a hash between variable names as Strings and 
thier associated values.  The Evaluator uses Scope values to store and retrieve
variables.

### Values.hs ###

This is the data structure for the Abstract Syntax Tree (ast).  It is far 
simpler then a full Lisp tree.  Only Integers may be past to compiled 
functions. The Interpreter also understands lists and functions.  The syntax of
the languages is built up in nested List structures as is common in Lisp.

Value is made an instance of `Show`.

### Error.hs  ###

Defines an error monad both by itself and layered on top of the IO monad and
provides a function to raise the former to the latter.

### Eval.hs ###

TODO

### Compile.hs ###

TODO


##Licence##

Copyright (c) 2011 John Miller

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


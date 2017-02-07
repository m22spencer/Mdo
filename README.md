### An alternative syntax for working with Monads. 
(Like C# Query Expressions, F# Computation Expressions, or Haskell's 'do' notation)

```haxe
future.flatMap(function(value) 
              return askServerSomething(value)
                        .flatMap(function(response) return Future.pure(response)));
```
Can be written using 'mdo' like so.
```
Mdo.mdo( value <= future
       , response <= askServerSomething(value)
       , Future.pure(response));
```

Additionally, you may place var bindings  
`foo <= Future.pure(bar)` may be written as `var foo = bar`

The value left of `<=` must be an identifier, `_`, or a typechecked identifier:
```haxe
myIdent <= ...
--or--
_       <= ...      (This means we don't care about the value)
--or--
(myIdent:MyType) <= ...
```

The type is not required, but can be useful in some situations. 

If no binding is supplied, it will be as if you've specified `_ <= ...`

When looking at types, you'll see:
```haxe
 T         M<T>
value <= monadicType
...
```
 
Since this is converted to: `monadicType.flatMap(function(value) return ...)`,
the monadic type in question, must have a flatMap implementation. This may be provided through using
or as a field on the type itself. Else, you will recieve a "Has no field 'flatMap'" error.
package mdo;

import haxe.macro.Expr;
import haxe.macro.Context in C;
using Lambda;

class Mdo {
    /** An alternative syntax for working with Monads. 
    *** (Like C# Query Expressions, F# Computation Expressions, or Haskell's 'do' notation)
    *** future.flatMap(function(value) 
    ***               return askServerSomething(value)
    ***                         .flatMap(function(response) return Future.pure(response)));
    *** Can be written using 'mdo' like so.
    *** Mdo.mdo( value <= future
    ***        , response <= askServerSomething(value)
    ***        , Future.pure(response));
    ***
    *** Additionally, you may place var bindings
    *** `foo <= Future.pure(bar)` may be written as `var foo = bar`
    ***
    *** The value left of <= must be an identifier, _, or a typechecked identifier:
    *** myIdent <= ...
    *** --or--
    *** _       <= ...      (This means we don't care about the value)
    *** --or--
    *** (myIdent:MyType) <= ...
    ***
    *** The type is not required, but can be useful in some situations.
    ***
    *** If no binding is supplied, it will be as if you've specified _ <= ...
    ***
    *** When looking at types, you'll see:
    ***  T         M<T>
    *** value <= monadicType
    *** ...
    ***  
    *** Since this is converted to: monadicType.flatMap(function(value) return ...),
    *** the monadic type in question, must have a flatMap implementation. This may be provieded through using
    *** or as a field on the type itself. Else, you will recieve a "Has no field 'flatMap'" error.
    **/
    macro public static function mdo(exps:Array<Expr>):Expr {
        if (exps.length == 0)
            C.error("mdo expects at least one argument", C.currentPos());

        var last = exps.pop();

        exps.reverse();

        //Build chain
        var code = exps.fold(function(a,b)
                                 return switch(a) {
                                 case macro $i{bind} <= $val:
                                     macro @:pos(val.pos) $val.flatMap(function($bind) return $b);
                                 case macro ($i{bind}:$type) <= $val:
                                     macro @:pos(val.pos) $val.flatMap(function($bind:$type) return $b);
                                 case macro var $name = $val:
                                     macro { $a; $b; };
                                 case macro var $name:$type = $val:
                                     macro { $a; $b; };
                                 case macro $inv <= $_:
                                     C.error("Invalid binding, must be identifier", inv.pos); 
                                 case _:
                                     macro @:pos(a.pos) $a.flatMap(function(_) return $b);
                                 }
                            , macro @:pos(last.pos) $last);
        
        return code;
    }
}

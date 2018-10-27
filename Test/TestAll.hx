package ;

import mdo.Mdo.mdo;

using Lambda;
using TestAll.TestExt;

import TestAll.assertEquals;

class TestAll {
    static function main() {
	var rt = new RunTests();
	Type.getInstanceFields(RunTests)
	    .filter(StringTools.startsWith.bind(_, "test"))
	    .map(Reflect.field.bind(rt))
	    .filter(Reflect.isFunction)
	    .map(function(fn) try fn() catch(e:Any) { failed = true; haxe.Log.trace('[EXN]'); });

	haxe.Log.trace(failed ? 'one or more tests failed' : 'all tests ok');
	Sys.exit(failed ? 1 : 0);
    }

    static var failed = false;
    public static function assertEquals(expected, found, ?pos:haxe.PosInfos) {
	if (expected != found) {
	    failed = true;
	    haxe.Log.trace('[FAIL]: Expected $expected but found $found', pos);
	} else {
	    haxe.Log.trace('[OK]');
	}
    }
}

class TestExt {
    public static function fail<T>(a:Array<Dynamic>):Array<T> {
	return [];
    }
}

class RunTests {
    public function new() {}

    public function testLHSPatternSimple() {
	var a = mdo( {x:1} <= [{x:0}, {x:1}, {x:2}]
		   , ["ok"]);
	var b = ["ok"];
	assertEquals('${a.array()}', '${b.array()}');
    }

    public function testLHSPatternComplex() {
	var a = mdo( {x:val = _ != 1 => true} <= [{x:0}, {x:1}, {x:2}]
		   , [val]);
	var b = [0, 2];
	assertEquals('${a.array()}', '${b.array()}');
    }

    public function testLeftIdentity() {
        function f(x:Int) return [x,x+10];

        var x = 5;
        var a = mdo( x_ <= [x]
                   , f(x_)
                   );
        var b = mdo( f(x) );

        assertEquals('${b.array()}', '${a.array()}');
    }

    public function testRightIdentity() {
        function f(x:Int) return [x,x+10];

        var m = [5];
        var a = mdo( x <= m
                   , [x]
                   );
        var b = mdo( m );

        assertEquals('${a.array()}', '${b.array()}');
    }

    public function testAssociativity1() {
        function f(x:Int) return [x,x+10];
        function g(x:Int) return [x*4,x*2,x+7];

        var m = [5];
        var a = mdo( y <= mdo( x <= m
                             , f(x)
                             )
                   , g(y)
                   );
        var b = mdo( x <= m
                   , mdo( y <= f(x)
                        , g(y)
                        )
                   );

        assertEquals('${a.array()}', '${b.array()}');
    }

    public function testAssociativity2() {
        function f(x:Int) return [x,x+10];
        function g(x:Int) return [x*4,x*2,x+7];

        var m = [5];
        var a = mdo( y <= mdo( x <= m
                             , f(x)
                             )
                   , g(y)
                   );
        var b = mdo( x <= m
                   , y <= f(x)
                   , g(y)
                   );

        assertEquals('${a.array()}', '${b.array()}');
    }

}
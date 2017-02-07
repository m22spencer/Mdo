package ;

import haxe.unit.*;

import mdo.Mdo.mdo;

using Lambda;

class TestAll {
    static function main() {
        var r = new TestRunner();
        r.add(new RunTests());
        Sys.exit(r.run() ? 0 : 1);
    }
}

class RunTests extends haxe.unit.TestCase {
    public function testLeftIdentity() {
        function f(x:Int) return [x,x+10];

        var x = 5;
        var a = mdo( x_ <= [x]
                   , f(x_)
                   );
        var b = mdo( f(x) );

        assertEquals('${a.array()}', '${b.array()}');
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
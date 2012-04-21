use t::CompileTestLib;
use NativeCall;
use Test;

plan 12;

compile_test_lib('06-struct');

class MyStruct is repr('CStruct') {
    has int    $.int;
    has num    $.num;
    has CArray $.arr;

    method init() {
        $!int = 42;
        $!num = -3.7e0;
        my $arr = CArray[int32].new();
        $arr[0] = 1;
        $arr[1] = 2;
        $!arr := $arr;
    }
}

# Workaround a Rakudo-bug where $!arr := CArray[int].new() won't work if $.arr
# is declared as type CArray[int].
class MyStruct2 is repr('CStruct') {
    has int         $.int;
    has num         $.num;
    has CArray[int] $.arr;
}

sub ReturnAStruct() returns MyStruct2 is native('06-struct') { * }
sub TakeAStruct(MyStruct $arg)        is native('06-struct') { * }

# Perl-side tests:
my MyStruct $obj .= new;
$obj.init;

is $obj.int,    42,    'getting int';
is $obj.num,   -3.7e0, 'getting num';
is $obj.arr[1], 2,     'getting CArray and element';

# C-side tests:

# NYI:
skip('NYI: Getting struct from C-land', 5);
#my $cobj = ReturnAStruct;
#
#is $cobj.int,    17,    'getting int from C-created struct';
#is $cobj.num,    4.2e0, 'getting num from C-created struct';
#is $cobj.arr[0], 2,     'C-created array member, elem 1';
#is $cobj.arr[1], 3,     'C-created array member, elem 2';
#is $cobj.arr[2], 5,     'C-created array member, elem 3';

TakeAStruct($obj);

# vim:ft=perl6

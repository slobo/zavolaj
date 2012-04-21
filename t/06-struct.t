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

class IntStruct is repr('CStruct') {
    has int $.first;
    has int $.second;

    # Work around struct members not being containerized yet.
    method init {
        $!first  = 13;
        $!second = 17;
    }
}

class NumStruct is repr('CStruct') {
    has num $.first;
    has num $.second;

    # Work around struct members not being containerized yet.
    method init {
        $!first  = 0.9e0;
        $!second = 3.14e0;
    }
}

class StructStruct is repr('CStruct') {
    has IntStruct $.a;
    has NumStruct $.b;

    # Work around struct members not being containerized yet.
    method init {
        $!a := IntStruct.new;
        $!b := NumStruct.new;
        $!a.init;
        $!b.init;
    }
}

sub ReturnAStruct() returns MyStruct2 is native('06-struct') { * }
sub TakeAStruct(MyStruct $arg)        is native('06-struct') { * }

sub ReturnAStructStruct() returns StructStruct is native('06-struct') { * }
sub TakeAStructStruct(StructStruct $arg)       is native('06-struct') { * }

# Perl-side tests:
my MyStruct $obj .= new;
$obj.init;

is $obj.int,    42,    'getting int';
is $obj.num,   -3.7e0, 'getting num';
is $obj.arr[1], 2,     'getting CArray and element';

# C-side tests:
my $cobj = ReturnAStruct;

is $cobj.int,    17,    'getting int from C-created struct';
is $cobj.num,    4.2e0, 'getting num from C-created struct';
is $cobj.arr[0], 2,     'C-created array member, elem 1';
is $cobj.arr[1], 3,     'C-created array member, elem 2';
is $cobj.arr[2], 5,     'C-created array member, elem 3';

my StructStruct $ss = ReturnAStructStruct();
is $ss.a.first,   7, 'field 1 from struct 1 in struct';
is $ss.a.second, 11, 'field 2 from struct 1 in struct';

is $ss.b.first,  3.7e0, 'field 1 from struct 1 in struct';
is $ss.b.second, 0.1e0, 'field 2 from struct 1 in struct';

TakeAStruct($obj);

my StructStruct $ss2 .= new();
$ss2.init;

TakeAStructStruct($ss2);

# vim:ft=perl6

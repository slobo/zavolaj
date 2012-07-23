use lib '.';
use t::CompileTestLib;
use NativeCall;
use Test;

plan(5);

compile_test_lib('08-callbacks');

class Struct is repr('CStruct') {
    has Str $.str;
    has int $.ival;
}

sub TakeACallback(&cb()) is native('./08-callbacks') { * }
sub TakeIntCallback(&cb(int)) is native('./08-callbacks') { * }
sub TakeStringCallback(&cb(Str)) is native('./08-callbacks') { * }
sub TakeStructCallback(&cb(Struct)) is native('./08-callbacks') { * }

sub simple_callback() {
    pass 'simple callback';
}

sub int_callback(int $x) {
    is $x, 17, 'int callback argument'
}

sub str_callback(Str $x) {
    is $x, 'lorem ipsum', 'string callback argument'
}

sub struct_callback(Struct $struct) {
    is $struct.str, 'foobar', 'struct callback string argument';
    is $struct.ival, -42, 'struct callback int argument';
}

TakeACallback(&simple_callback);
TakeIntCallback(&int_callback);
TakeStringCallback(&str_callback);
TakeStructCallback(&struct_callback);

# vim:ft=perl6

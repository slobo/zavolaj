use t::CompileTestLib;
use NativeCall;

say "1..6";

compile_test_lib('02-simple-args-and-returns');

sub TakeInt(int32) is native('02-simple-args-and-returns') { * }
sub TakeTwoShorts(int16, int16) is native('02-simple-args-and-returns') { * }
sub AssortedIntArgs(int32, int16, int8) is native('02-simple-args-and-returns') { * }

TakeInt(42);
TakeTwoShorts(10, 20);
AssortedIntArgs(101, 102, 103);

use lib '.';
use t::CompileTestLib;
use NativeCall;

say "1..12";

compile_test_lib('02-simple-args');

# Int related
sub TakeInt(int32) is native('./02-simple-args') { * }
sub TakeTwoShorts(int16, int16) is native('./02-simple-args') { * }
sub AssortedIntArgs(int32, int16, int8) is native('./02-simple-args') { * }
TakeInt(42);
TakeTwoShorts(10, 20);
AssortedIntArgs(101, 102, 103);

# Float related
sub TakeADouble(num64) is native('./02-simple-args') { * }
sub TakeAFloat(num32) is native('./02-simple-args') { * }
TakeADouble(-6.9e0);
TakeAFloat(4.2e0);

# String related
sub TakeAString(Str) is native('./02-simple-args') { * }
TakeAString('ok 9 - passed a string');

# Explicitly managing strings
sub SetString(Str) is native('./02-simple-args') { * }
sub PrintString() is native('./02-simple-args') { * }
my $str = 'ok 10 - delayed string print';
explicitly-manage($str);
SetString($str);
PrintString();

# Make sure wrapped subs work
sub wrapped(int) is native('./02-simple-args') { * }
sub wrapper(int $arg) { wrapped($arg) }

wrapper(1);

# Make sure we can call functions from the C library. Not an issue on Linux,
# but OS X has a distinction between shared libraries (dylibs) and loadable
# modules (bundles) which we need to check.
sub printf(Str) is native('libc') { * }
printf('ok 12 - printf(3) from libc');

# vim:ft=perl6

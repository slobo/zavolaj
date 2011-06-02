# zavolaj t/03-customlib.t
# To successfully run this test script, ensure the library loader path
# includes the directory containing libzavolajtest.so, for example:
# make lib/libzavolajtest.so && \
#     PERL6LIB=lib LD_LIBRARY_PATH=lib perl6 t/03-customlib.t

use Test;
use NativeCall;
plan 6;

# double (Num) return
diag 'functions that return a double precision floating point number';
sub test_d() returns Num is native('libzavolajtest'){ ... }
is test_d(), 42.424242424242, 'test_d()';                            # 1
sub test_dd(Num $d) returns Num is native('libzavolajtest'){ ... }
is test_dd(28.282828008), 42.424242012, 'test_dd(28.282828008)';     # 2

# int (Int) return
sub test_i() returns Int is native('libzavolajtest'){ ... }
is test_i(), 4242, 'test_i()';                                       # 3
sub test_ii(Int $i) returns Int is native('libzavolajtest'){ ... }
is test_ii(21), 63, 'test_ii(21)';                                   # 4
sub test_ip(Str $s) returns Int is native('libzavolajtest'){ ... }
is test_ip("abcde"), 5, 'test_ip("abcde")';                          # 5

# pointer (Str) return
sub test_p() returns Str is native('libzavolajtest'){ ... }
is test_p(), "foobar", 'test_p()';                                   # 6


#abort: Invalid character in ASCII string
#sub test_pi(Str $s) returns Str is native('libzavolajtest'){ ... }
#is test_pi(0x36), "66", 'test_pi(0x36)';

#abort: Invalid character in ASCII string
#sub test_pp(Str $s) returns Str is native('libzavolajtest'){ ... }
#is test_pp("abcde"), "bcdef", 'test_pp("abcde")';


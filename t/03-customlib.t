# zavolaj t/03-customlib.t
# To successfully run this test script, ensure the library loader path
# includes the directory containing libzavolajtest.so, for example:
# make lib/libzavolajtest.so && \
#     PERL6LIB=lib LD_LIBRARY_PATH=lib perl6 t/03-customlib.t

use Test;
use NativeCall;
plan 11;

# double (Num) return
diag 'functions that return a double precision floating point number';
sub test_d() returns Num is native('libzavolajtest'){ ... }
is test_d(), 42.424242424242, 'test_d() is 42.424242424242';         # 1
sub test_dd(Num $d) returns Num is native('libzavolajtest'){ ... }
is test_dd(28.282828008), 42.424242012, 'test_dd(28.282828008) is 42.424242012'; # 2

# int (Int) return
diag 'functions that return an integer';
sub test_i() returns Int is native('libzavolajtest'){ ... }
is test_i(), 4242, 'test_i() is 4242';                               # 3
sub test_ii(Int $i) returns Int is native('libzavolajtest'){ ... }
is test_ii(21), 63, 'test_ii(21) is 63';                             # 4
sub test_iii(Int $i1, Int $i2) returns Int is native('libzavolajtest'){ ... }
is test_iii(7,-6), -42, 'test_iii(7,-6) is -42';                     # 5
sub test_ip(Str $s) returns Int is native('libzavolajtest'){ ... }
is test_ip("abcde"), 5, 'test_ip("abcde") is 5';                     # 6
sub test_ipp(Str $s1, Str $s2) returns Int is native('libzavolajtest'){ ... }
is test_ipp("abcde","cd"), 2, 'test_ipp("abcde","cd") is 2';         # 7
# array of int (Positional of Int) return
sub test_I() returns Positional of Int is native('libzavolajtest'){ ... }
ok test_I().WHAT ~~ NativeArray, 'test_I().WHAT ~~ NativeArray';     # 8

# pointer (OpaquePointer) return


# pointer (Str) return
diag 'functions that return a string';
sub test_s() returns Str is native('libzavolajtest'){ ... }
is test_s(), "foobar", 'test_p() is "foobar"';                       # 9
sub test_si(Int $i) returns Str is native('libzavolajtest'){ ... }
is test_si(0x37), "777777", 'test_pi(0x37) is "7777777"';           # 10
sub test_ss(Str $s) returns Str is native('libzavolajtest'){ ... }
is test_ss("foo"), "foofoo", 'test_pp("foo") is "foofoo"';          # 11


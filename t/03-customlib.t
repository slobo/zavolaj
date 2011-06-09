# zavolaj t/03-customlib.t
# To successfully run this test script, ensure the library loader path
# includes the directory containing libzavolajtest.so, for example:
# make lib/libzavolajtest.so && \
#     PERL6LIB=lib LD_LIBRARY_PATH=lib perl6 t/03-customlib.t

use Test;
use NativeCall;
plan 15;

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
diag 'functions that return or pass a pointer';
sub test_Ii(Int $i) returns OpaquePointer is native('libzavolajtest'){ ... }
sub test_iIi(OpaquePointer $op, Int $i) returns Int is native('libzavolajtest'){ ... }
sub test_vI(OpaquePointer $op) is native('libzavolajtest'){ ... }
sub test_vIi(OpaquePointer $op, Int $i1) is native('libzavolajtest'){ ... }
sub test_vIii(OpaquePointer $op, Int $i1, Int $i2) is native('libzavolajtest'){ ... }
# The following tests do not all return OpaquePointers, but they should
# verify the correct use of the OpaquePointer in $op1.
my $op1 = test_Ii(4); # allocate 4 ints on the heap
ok defined($op1), 'got heap pointer';                                # 9

#error: Null PMC access in type(), at line 88:lib/NativeCall.pm6>, at line 111:lib/NativeCall.pm6
#test_vIii($op1,2,41); # store 41 into int 2

is test_iIi($op1,2), 41, 'test_iIi($op1,2) is 41';                  # 10

#error: Null PMC access in type(), at line 88:lib/NativeCall.pm6, at line 111:lib/NativeCall.pm6
#test_vIi($op1,2); # increment int 2
is test_iIi($op1,2), 42, 'test_iIi($op1,2) is 42';                  # 11

#error: Null PMC access in type(), at line 88:lib/NativeCall.pm6, at line 111:lib/NativeCall.pm6
#test_vI($op1); # free the library's heap memory
skip 'NativeCall cannot handle void return value', 1;
#ok True, 'freed heap pointer';                                     # 12

# pointer (Str) return
diag 'functions that return a string';
sub test_s() returns Str is native('libzavolajtest'){ ... }
is test_s(), "foobar", 'test_p() is "foobar"';                      # 13
sub test_si(Int $i) returns Str is native('libzavolajtest'){ ... }
is test_si(0x37), "777777", 'test_pi(0x37) is "7777777"';           # 14
sub test_ss(Str $s) returns Str is native('libzavolajtest'){ ... }
is test_ss("foo"), "foofoo", 'test_pp("foo") is "foofoo"';          # 15


# zavolaj t/03-customlib.t
# To successfully run this test script, ensure the library loader path
# includes the directory containing

use Test;
use NativeCall;
plan 2;

# double return
diag 'functions that return a double precision floating point number';
sub test_d() returns Num is native('libzavolajtest'){ ... }
is test_d(), 42.424242424242, 'test_d()';

# int return
sub test_i() returns Int is native('libzavolajtest'){ ... }
is test_i(), 4242, 'test_i()';


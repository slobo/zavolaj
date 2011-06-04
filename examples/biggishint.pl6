# biggishint.pl6
# Demonstration of the biggishint library, which does arithmetic with
# integers up to 524240 bits long.
#
# To make the library from the source code on Linux, do:
#   cc -o biggishint.o -fPIC -c biggishint.c
#   cc -shared -s -o biggishint.so biggishint.o
#
# To run this script, use a command line similar to this:
#   PERL6LIB=../lib LD_LIBRARY_PATH=. perl6 biggishint.pl6
# or if you prefer shorter command lines:
#   export PERL6LIB=../lib LD_LIBRARY_PATH=.
#   perl6 biggishint.pl6

use NativeCall;
sub biggishintAdd(OpaquePointer $bi1, OpaquePointer $bi2) returns OpaquePointer is native('biggishint') {...}
sub biggishintFromHexadecimalString(Str $s) returns OpaquePointer is native('biggishint') {...}
sub biggishintMultiply(OpaquePointer $bi1, OpaquePointer $bi2) returns OpaquePointer is native('biggishint') {...}
sub biggishintToHexadecimalString(OpaquePointer $bi1) returns Str is native('biggishint') {...}
sub biggishintToDecimalString(OpaquePointer $bi1) returns Str is native('biggishint') {...}

my $s1 = '0x10000';
my $s2 = '0x10000';
my $bi1 = biggishintFromHexadecimalString($s1);
my $bi2 = biggishintFromHexadecimalString($s2);
my $bi3 = biggishintMultiply($bi1, $bi2);
my $s3 = biggishintToDecimalString($bi3);
say $s3;

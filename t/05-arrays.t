use t::CompileTestLib;
use NativeCall;
use Test;

plan 4;

compile_test_lib('05-arrays');

sub ReturnADoubleArray() returns CArray[num] is native("05-arrays") { * }
my @rarr := ReturnADoubleArray();
is_approx @rarr[0], 23.45e0, 'returning double array (1)';
is_approx @rarr[1], -99.87e0, 'returning double array (1)';
is_approx @rarr[2], 0.25e0, 'returning double array (1)';

sub TakeADoubleArrayAndAddElements(CArray[num]) returns num is native("05-arrays") { * }
my @parr := CArray[num].new();
@parr[0] = 9.5e0;
@parr[1] = 32.5e0;
is_approx TakeADoubleArrayAndAddElements(@parr), 42e0, 'passing double array';


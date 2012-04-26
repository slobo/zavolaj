use t::CompileTestLib;
use NativeCall;
use Test;

plan 16;

compile_test_lib('05-arrays');

{
    sub ReturnADoubleArray() returns CArray[num] is native("./05-arrays") { * }
    my @rarr := ReturnADoubleArray();
    is_approx @rarr[0], 23.45e0, 'returning double array (1)';
    is_approx @rarr[1], -99.87e0, 'returning double array (2)';
    is_approx @rarr[2], 0.25e0, 'returning double array (3)';

    sub TakeADoubleArrayAndAddElements(CArray[num]) returns num is native("./05-arrays") { * }
    my @parr := CArray[num].new();
    @parr[0] = 9.5e0;
    @parr[1] = 32.5e0;
    is_approx TakeADoubleArrayAndAddElements(@parr), 42e0, 'passing double array';
}

{
    sub ReturnAStringArray() returns CArray[Str] is native("./05-arrays") { * }
    my @rarr := ReturnAStringArray();
    is @rarr[0], 'La Trappe', 'returning string array (1)';
    is @rarr[1], 'Leffe', 'returning string array (2)';
    
    sub TakeAStringArrayAndReturnTotalLength(CArray[Str]) returns int32 is native("./05-arrays") { * }
    my @parr := CArray[Str].new();
    @parr[0] = "OMG";
    @parr[1] = "strings!!!";
    is TakeAStringArrayAndReturnTotalLength(@parr), 13, 'passing string array';
}

{
    my @arr := CArray[int].new();
    @arr[0] = 1;
    is @arr[0], 1, 'getting last element of managed array';
}

{
    my @arr := CArray[OpaquePointer].new;
    @arr[1] = OpaquePointer;
    my $x = @arr[0];
    pass 'getting uninitialized element in managed array';
}

{
    class Struct is repr('CStruct') {
        has int $.val;

        method set($x) {
            $!val = $x;
        }
    }

    sub ReturnAStructArray() returns CArray[Struct] is native("./05-arrays") { * }
    my @arr := ReturnAStructArray();
    is @arr[0].val, 2, 'int in struct in element 0';
    is @arr[1].val, 3, 'int in struct in element 1';
    is @arr[2].val, 5, 'int in struct in element 2';

    sub TakeAStructArray(CArray[Struct] $obj) is native("./05-arrays") { * }
    @arr := CArray[Struct].new;
    @arr[0] = Struct.new();
    @arr[1] = Struct.new();
    @arr[2] = Struct.new();
    @arr[0].set(7);
    @arr[1].set(11);
    @arr[2].set(13);

    is_deeply @arr[100], Struct, 'out-of-bounds access on managed array';

    # runs tests no 13, 14, 15
    TakeAStructArray(@arr);
}

# vim:ft=perl6

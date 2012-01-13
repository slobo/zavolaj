use NativeCall;

sub MessageBoxA(Int, Str, Str, Int)
    returns Int
    is native('user32.dll')
    { * }

MessageBoxA(0, "We can haz NCI?", "oh lol", 64);

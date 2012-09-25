use NativeCall;

sub MessageBoxA(int32, Str, Str, int32)
    returns Int
    is native('user32.dll')
    { * }

MessageBoxA(0, "We can haz NCI?", "oh lol", 64);

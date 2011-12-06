use NativeCall;

sub MessageBoxA(int32 $phWnd, Str $message, Str $caption, int32 $flags)
    returns Int
    is native('user32')
    { ... }

MessageBoxA(0, "We can haz NCI?", "oh lol", 64);

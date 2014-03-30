module t::CompileTestLib;

sub compile_test_lib($name) is export {
    my ($c_line, $l_line);
    if $*VM<name> eq 'parrot' {
        my $o  = $*VM<config><o>;
        my $so = $*VM<config><load_ext>;
        $c_line = "$*VM<config><cc> -c $*VM<config><cc_shared> $*VM<config><cc_o_out>$name$o $*VM<config><ccflags> t/$name.c";
        $l_line = "$*VM<config><ld> $*VM<config><ld_load_flags> $*VM<config><ldflags> " ~
            "$*VM<config><libs> $*VM<config><ld_out>$name$so $name$o";
    }
    elsif $*VM<name> eq 'moar' {
        my $o  = $*VM<config><obj>;
        my $so = $*VM<config><dll>;
        $so ~~ s/^.*\%s//;
        $c_line = "$*VM<config><cc> -c $*VM<config><ccshared> $*VM<config><ccout>$name$o $*VM<config><cflags> t/$name.c";
        $l_line = "$*VM<config><ld> $*VM<config><ldshared> $*VM<config><ldflags> " ~
            "$*VM<config><ldlibs> $*VM<config><ldout>$name$so $name$o";
    }
    elsif $*VM<name> eq 'jvm' {
        #say "$*VM<config><nativecall.ccdlflags>";
        my $cfg = $*VM<config>;
        $c_line = "$cfg<nativecall.cc> -c $cfg<nativecall.ccdlflags> -o$name$cfg<nativecall.o> $cfg<nativecall.ccflags> t/$name.c";
        $l_line = "$cfg<nativecall.ld> $cfg<nativecall.perllibs> $cfg<nativecall.lddlflags> $cfg<nativecall.ldflags> $cfg<nativecall.ldout>$name.$cfg<nativecall.so> $name$cfg<nativecall.o>";
    }
    else {
        die "Unknown VM; don't know how to compile test libraries";
    }
    shell($c_line);
    shell($l_line);
}

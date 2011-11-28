module NativeCall;

# Throwaway type just to get us some way to get at the NativeCall
# representation.
my class native_callsite is repr('NativeCall') { }

# Maps a chosen string encoding to a type recognized by the native call engine.
sub string_encoding_to_nci_type($enc) {
    given $enc {
        when 'utf8'  { 'utf8str'  }
        when 'utf16' { 'utf16str' }
        when 'ascii' { 'asciistr' }
        default      { die "Unknown string encoding for native call: $enc"; }
    }
}

# Builds a hash of type information for the specified parameter.
sub param_hash_for(Parameter $p) {
    my Mu $result := nqp::hash();
    my $type := $p.type();
    if $type ~~ Str {
        my $enc := $p.?native_call_encoded() || 'utf8';
        nqp::bindkey($result, 'type', nqp::unbox_s(string_encoding_to_nci_type($enc)));
        nqp::bindkey($result, 'free_str', nqp::unbox_i(1));
    }
    else {
        nqp::bindkey($result, 'type', nqp::unbox_s(type_code_for($p.type)));
    }
    $result
}

# Builds a hash of type information for the specified return type.
sub return_hash_for(&r) {
    my Mu $result := nqp::hash();
    my $returns := &r.returns;
    if $returns ~~ Str {
        my $enc := &r.?native_call_encoded() || 'utf8';
        nqp::bindkey($result, 'type', nqp::unbox_s(string_encoding_to_nci_type($enc)));
        nqp::bindkey($result, 'free_str', nqp::unbox_i(0));
    }
    else {
        nqp::bindkey($result, 'type',
            $returns =:= Mu ?? 'void' !! nqp::unbox_s(type_code_for($returns)));
    }
    $result
}

# Gets the NCI type code to use based on a given Perl 6 type.
my %type_map =
    'int8'  => 'char',
    'int16' => 'short',
    'int32' => 'int',
    'int'   => 'long',
    'Int'   => 'longlong',
    'num32' => 'float',
    'num64' => 'double',
    'num'   => 'double',
    'Num'   => 'double';
sub type_code_for(Mu ::T) {
    return %type_map{T.^name}
        if %type_map.exists(T.^name);
    return 'cstruct'
        if T.REPR eq 'CStruct';
    return 'cpointer'
        if T.REPR eq 'CPointer';
    die "Unknown type {T.^name} used in native call.\n" ~
        "If you want to pass a struct, be sure to use the CStruct representation.\n" ~
        "If you want to pass an array, be sure to use the CArray type.";
}

# This role is mixed in to any routine that is marked as being a
# native call.
my role Native[Routine $r, Str $libname] {
    has int $!setup;
    has native_callsite $!call is box_target;
    
    method postcircumfix:<( )>($args) {
        unless $!setup {
            my Mu $arg_info := nqp::list();
            for $r.signature.params -> $p {
                nqp::push($arg_info, param_hash_for($p))
            }
            my str $conv = self.?native_call_convention || '';
            nqp::buildnativecall(self,
                nqp::unbox_s($libname),     # library name
                nqp::unbox_s($r.name),      # symbol to call
                nqp::unbox_s($conv),        # calling convention
                $arg_info,
                return_hash_for($r));
            $!setup = 1;
        }
        nqp::nativecall(nqp::p6decont($r.returns), self,
            nqp::getattr(nqp::p6decont($args), Capture, '$!list'))
    }
}

# Role for carrying extra calling convention information.
my role NativeCallingConvention[$name] {
    method native_call_convention() { $name };
}

# Role for carrying extra string encoding information.
my role NativeCallEncoded[$name] {
    method native_call_encoded() { $name };
}

# Expose an OpaquePointer class for working with raw pointers.
my class OpaquePointer is export is repr('CPointer') { }

# Specifies that the routine is actually a native call, and gives
# the name of the library to load it from.
multi trait_mod:<is>(Routine $r, $libname, :$native!) is export {
    $r does Native[$r, $libname];
}

# Specifies the calling convention to use for a native call.
multi trait_mod:<is>(Routine $r, $name, :$nativeconv!) is export {
    $r does NativeCallingConvention[$name];
}

# Ways to specify how to marshall strings.
multi trait_mod:<is>(Parameter $p, $name, :$encoded!) is export {
    $p does NativeCallEncoded[$name];
}
multi trait_mod:<is>(Routine $p, $name, :$encoded!) is export {
    $p does NativeCallEncoded[$name];
}

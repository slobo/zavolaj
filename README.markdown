# Zavolaj!

This module implements native calling support for Rakudo Perl 6. It builds
on a set of native calling primitives in NQP, adding mapping of Perl 6
signatures and various other traits to make working with native libraries
an easier experience.

The project name is the Slovak translation of the imperative "call!", to
complement Blizkost, a Rakudo-to-Perl-5 integration project.

Thanks to NQP's underlying use of the dyncall library, Zavolaj can now
support arbitrary signatures.

## Getting Started
The simplest imaginable use of Zavolaj would look something like this:

    use NativeCall;
    sub some_argless_function() is native('libsomething') { * }
    some_argless_function();

The first line imports various traits and types. The next line looks like
a relatively ordinary Perl 6 sub declaration - with a twist. We use the
"native" trait in order to specify that the sub is actually defined in a
native library. The platform-specific extension (e.g. .so or .dll) will be
added for you.

The first time you call "some_argless_function", the "libsomething" will be
loaded and the "some_argless_function" will be located in it. A call will then
be made. Subsequent calls will be faster, since the symbol handle is retained.

Of course, most functions take arguments or return values - but everything else
that you can do is just adding to this simple pattern of declaring a Perl 6
sub, naming it after the symbol you want to call and marking it with the "native"
trait.

## Passing and Returning Values
Normal Perl 6 signatures and the "returns" trait are used in order to convey
the type of arguments a native function expects and what it returns. Here is
an example.

    sub add(int32, int32) returns int32 is native("libcalculator") { * }

Here, we have declared that the function takes two 32-bit integers and returns
a 32-bit integer. Here are some of the other types that you may pass (this will
likely grow with time).

    int8     (char in C)
    int16    (short in C)
    int32    (int in C)
    int      (32- or 64-bit, depends what long means locally)
    Int      (always 64-bit, long long in C)
    num32    (float in C)
    num64    (double in C)
    num      (same as num64)
    Str      (C string)

Note that the lack of a "returns" trait is used to indicate void return type.

For strings, there is an additional "encoded" trait to give some extra hints on
how to do the marshalling.

    sub message_box(Str is encoded('utf8')) is native('libgui') { * }

To specify how to marshall string return types, just apply this trait to the
routine itself.

    sub input_box() returns Str is encoded('utf8') is native('libgui') { * }


## Opaque Pointers
Sometimes you need to get a pointer (for example, a library handle) back from a
C library. You don't care about what it points to - you just need to keep hold
of it. The OpaquePointer type provides for this.

    sub Foo_init() returns OpaquePointer is native("libfoo") { * }
    sub Foo_free(OpaquePointer) is native("libfoo") { * }

This works out OK, but you may fancy working with a type named something better
than OpaquePointer. It turns out that any class with the representation "CPointer"
can serve this role. This means you can expose libraries that work on handles
by writing a class like this:

    class FooHandle is repr('CPointer') {
        # Here are the actual Zavolaj functions.
        sub Foo_init() returns FooPointer is native("libfoo") { * }
        sub Foo_free(FooPointer) is native("libfoo") { * }
        
        # Here are the methods we use to expose it to the outside world.
        method new() { Foo_init() }
        method free() { Foo_free(self) }
    }

Note that the CPointer representation can do nothing more than hold a C pointer.
This means that your class cannot have extra attributes. However, for simple
libraries this may be a neat way to expose an object oriented interface to it.

Of course, you can always have an empty class:

    class DoorHandle is repr('CPointer') { }

And just use the class as you would use OpaquePointer, but with potential for
better type safety and more readable code.


## Running the Examples

The examples directory contains various examples of how to use Zavolaj.

### MySQL

There is an exmaple of using the MySQL client library. There is a Rakudo project
http://github.com/mberends/minidbi that wraps these functions with a DBI
compatible interface. You'll need that library to hand; on Debian-esque systems
it can be installed with something like:

    sudo apt-get install libmysqlclient-dev

Prepare your system along these lines before trying out the examples:

    $ mysql -u root -p
    CREATE DATABASE zavolaj;
    CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpass';
    GRANT CREATE      ON zavolaj.* TO 'testuser'@'localhost';
    GRANT DROP        ON zavolaj.* TO 'testuser'@'localhost';
    GRANT INSERT      ON zavolaj.* TO 'testuser'@'localhost';
    GRANT DELETET     ON zavolaj.* TO 'testuser'@'localhost';
    GRANT SELECT      ON zavolaj.* TO 'testuser'@'localhost';
    GRANT LOCK TABLES ON zavolaj.* TO 'testuser'@'localhost';
    GRANT SELECT      ON   mysql.* TO 'testuser'@'localhost';
    # or maybe otherwise
    GRANT ALL PRIVILEGES ON zavolaj.* TO 'testuser'@'localhost';

You can look at the results via a normal mysql connection:

    $ mysql -utestuser -ptestpass
    USE zavolaj;
    SHOW TABLES;
    SELECT * FROM nom;

## SQLite3

May not be working...let us know if you get success!

## Microsoft Windows

The win32-api-call.p6 script shows a Windows API call done from Perl 6.

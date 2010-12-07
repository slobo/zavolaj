# sqlite3.p6

# An attempt to use libsqlite3-dev via zavolaj and Parrot NCI;

# This example does not work yet, because Parrot probably needs at least
# the following signatures added to parrot/src/nci/extra_thunks.nci:
#
#   iptppp      sqlite3_exec()
#   iptipp      sqlite3_prepare_v2()
#   iptttppppp  sqlite3_table_column_metadata()
#
# There will probably be others that will only become apparent after
# these are tried out.

use NativeCall;

# -------- foreign function definitions in alphabetical order ----------

# See http://sqlite.org/capi3ref.html and http://sqlite.org/quickstart.html

sub sqlite3_close( OpaquePointer $ppDB )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_column_count( OpaquePointer $ppStmt )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_column_text( OpaquePointer $ppStmt, Int $iCol )
    returns Str
    is native('libsqlite3')
    { ... }

sub sqlite3_column_type( OpaquePointer $ppStmt, Int $iCol )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_exec( OpaquePointer $ppDB, Str $sql_command, OpaquePointer $callback, OpaquePointer $callbackarg0, OpaquePointer $error_pointer )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_finalize( OpaquePointer $ppStmt )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_open( Str $filename, OpaquePointer $ppDB is rw )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_open_v2( Str $filename, OpaquePointer $ppDB is rw, Int $flags, Str $zVfs )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_prepare_v2( OpaquePointer $ppDB, Str $sql_command, Int $nByte, OpaquePointer $ppStmt is rw, OpaquePointer $pzTail is rw)
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_step( OpaquePointer $ppStmt )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_table_column_metadata(OpaquePointer $ppDB, Str $zDbName, Str $zTableName, Str $zColumnName, Positional of Str $pzDataType, Positional of Str $pzCollSeq, Positional of Int $pNotNull, Positional of Int $pPrimaryKey, Positional of Int $pAutoinc )
    returns Int
    is native('libsqlite3')
    { ... }

sub sqlite3_errmsg(OpaquePointer $ppDB)
    returns Str
    is native('libsqlite3')
    { ... }

# ----------------------- main example program -------------------------

sub report_status(Int $status, Str $op) {
  say "$op status: $status";
  say sqlite3_errmsg($db) if $status;
}


my $db = pir::new__Ps('UnManagedStruct');
my $stmt = pir::new__Ps('UnManagedStruct');
my $pzTail = pir::new__Ps('UnManagedStruct');
my Positional of Str $pzDataType;
my Positional of Str $pzCollSeq;
my Positional of Int $pNotNull;
my Positional of Int $pPrimaryKey;
my Positional of Int $pAutoinc;

my $status = sqlite3_open( "test.db", $db );
report_status($status, 'open');
$status = sqlite3_exec( $db, "CREATE TABLE a ( b INT );", pir::null__P(), pir::null__P(), pir::null__P() );
report_status($status, 'exec');

$status = sqlite3_prepare_v2( $db, "CREATE TABLE a ( b INT );", -1, $stmt, $pzTail );
report_status($status, 'prepare');

$status = sqlite3_table_column_metadata($db,
    pir::null__P(),"a","b",
    $pzDataType,$pzCollSeq,$pNotNull,$pPrimaryKey,$pAutoinc);
report_status($status, 'table_column_metadata');

$status = sqlite3_column_text( $stmt, 1 );
say "column text returns: $status";

$status = sqlite3_step( $stmt );
report_status($status, 'step');

$status = sqlite3_finalize( $stmt );
report_status($status, 'finalize');

$status = sqlite3_exec( $db, "
    CREATE TABLE nom (
        name char(4),
        description char(30),
        quantity int,
        price numeric(5,2)
    )
", pir::null__P(), pir::null__P(), pir::null__P());
report_status($status, 'exec');

$status = sqlite3_exec( $db, "
    INSERT INTO nom (name, description, quantity, price)
    VALUES ( 'BUBH', 'Hot beef burrito',         1, 4.95 )
", pir::null__P(), pir::null__P(), pir::null__P());
report_status($status, 'insert');

$status = sqlite3_exec( $db, "
    INSERT INTO nom (name, description, quantity, price)
    VALUES ( 'TAFM', 'Mild fish taco',           1, 4.85 )
", pir::null__P(), pir::null__P(), pir::null__P());
report_status($status, 'insert');

$status = sqlite3_exec( $db, "
    INSERT INTO nom (name, description, quantity, price)
    VALUES ( 'BEOM', 'Medium size orange juice', 2, 1.20 )
", pir::null__P(), pir::null__P(), pir::null__P());
report_status($status, 'insert');

$status = sqlite3_prepare_v2( $db, "SELECT * FROM nom;", -1, $stmt, $pzTail );
report_status($status, 'prepare');

$status = sqlite3_step($stmt);
report_status($status, 'step');
while $status == 100 {
    my $columns = sqlite3_column_count($stmt);
    for 0 .. $columns - 1 -> $col {
        my $text = sqlite3_column_text($stmt, $col);
        print "\t", $text;
    }
    say '';
    $status = sqlite3_step($stmt);
    report_status($status, 'step');
};
$status = sqlite3_finalize($stmt);
report_status($status, 'finalize');

$status = sqlite3_close( $db );
report_status($status, 'close');



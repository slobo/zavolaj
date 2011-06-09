/* libzavolajtest.h */

/* Functions to test the most useful signatures defined in: */
/* https://github.com/parrot/parrot/blob/master/src/nci/extra_thunks.nci */
/* Zavolaj's NativeCall.pm6 in map-type-to-sig-char() supports only */
/* the following Perl 6 to Parrot data type mappings: */
/*   Int           => i  # int */
/*   Str           => t  # (deprecated) */
/*   Num           => d  # double */
/*   Rat           => d  # double */
/*   OpaquePointer => p  # pointer */
/*   Positional    => p  # pointer */



/* Functions sorted alphabetically by return type and parameter types */

/* double return */
double test_d();
double test_dd(double);

/* float return */

/* int return */
int test_i();
int test_ii(int);
int test_iii(int, int);
int test_ip(char *);
int test_ipp(char *, char *);

/* array of int return */
int * test_I();
int * test_Ii(int);

/* pointer (string) return */
char * test_s();
char * test_si(int);
char * test_ss(char *);

/* void return */
void test_v();
void test_vi(int);
void test_vI(int *);
void test_vIi(int *, int);

/* end of libzavolajtest.h */

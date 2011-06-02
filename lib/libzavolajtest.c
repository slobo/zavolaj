/* libzavolajtest.c */

//#include <stdio.h>  /* printf */
#include <string.h>  /* strlen */
#include "libzavolajtest.h"  /* say_ok_1 */

/* double return */
double test_d() { double d = 42.424242424242; return d; }
double test_dd(double d1) { double d = d1*1.5; return d; }

/* int return */
int test_i() {int i=4242; return i;}
int test_ii(int i1) { int i = i1+42; return i; }
int test_ip(char * s1) {int i = strlen(s1); return i; }

/* pointer (string) return */
char ts[80];
char * test_p() {char * s = "foobar"; return s;}
char * test_pi(int i) {char *s=ts; *s++=i; *s++=i; *s++=0; return ts;}
char * test_pp(char * s1) {char c, *s=s1; while(c=*s){*s++ = ++c;} return s1;}

/* end of libzavolajtest.c */

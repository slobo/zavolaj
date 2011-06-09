/* libzavolajtest.c */

#include <stdlib.h>  /* calloc */
#include <string.h>  /* strlen, strstr */
#include "libzavolajtest.h"  /* say_ok_1 */

/* double return */
double test_d() { double d = 42.424242424242; return d; }
double test_dd(double d1) { double d = d1*1.5; return d; }

/* int return */
int tia[10];
int test_i() {int i=4242; return i;}
int test_ii(int i1) { int i = i1+42; return i; }
int test_iii(int i1, int i2) { int i = i1 * i2; return i; }
int test_ip(char * s1) {int i = strlen(s1); return i; }
int test_ipp(char * s1, char * s2) {int i = strstr(s1,s2)-s1; return i; }
int test_iI(int * ia) {return ia[0];}
int test_iIi(int * ia, int i) {return ia[i];}

/* array of int return */
int * test_I() {int i; for(i=0;i<10;++i){tia[i]=i++;}; return tia; }
int * test_Ii(int size) {int * ia = (int *)calloc(size,sizeof(int)); return ia; }

/* pointer (string) return */
char st[80];
char * test_s() {strcpy(st,"foobar"); return st;}
char * test_si(int i) {strcpy(st,"abcdef"); memset(st,i,6); return st;}
char * test_ss(char * s1) {strcpy(st,s1); strcat(st,s1); return st;}

/* void return */
void test_vI(int * ia) {free(ia);}
void test_vIi(int * ia, int i) {ia[i]++;}
void test_vIii(int * ia, int i1, int i2) {ia[i1]=i2;}

/* end of libzavolajtest.c */

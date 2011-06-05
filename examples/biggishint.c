/* biggishint.c */
/* Biggish integers in this library are arrays of up 32766 16-bit */
/* (unsigned short) integers for arbitrary precision integer */
/* arithmetic up to 524240-bit (16*32765 bit) numbers. */

/* The data format for these (fairly) big integers is an array of  */
/* short ints allocated on the heap, with the following layout: */
/* +--------------------------------+-------------------------------+ */
/* |     required (2 short ints)    |  optional (up to 16382 times) | */
/* |    word 0       |    word 1    |    word 2     |    word 3 etc | */
/* | 14 bits: size   | 16 bits: int | 16 bits: int  | 16 bits: int  | */
/* | 1 bit: overflow |              |               |               | */
/* | 1 bit: sign     |              |               |               | */
/* +-----------------+--------------+---------------+---------------+ */
/* Word 0 uses 14 bits for the size in units of pairs of short ints, */
/* 1 bit for overflow/underflow and 1 bit for (minus) sign. */
/* The remaining words are all unsigned short integers, always an odd */
/* number of them because of word 0 and the even array size.  Thus */
/* memory allocation occurs in multiples of 4 bytes, a nice alignment */
/* compromise between small and large processor types. */

/* The most compact biggishint uses 4 bytes to count from -65536 to */
/* +65535, the next size (8 bytes) spans -281474976710656 (-2^48) to */
/* +281474976710655 (+2^48-1), and so on to the largest (65532 bytes) */
/* calculating from about -9.22e157811 (-2^524240) to about */
/* +9.22e157811 (+2^524240-1). */

/* The word order is big endian, no matter what the byte order of the */
/* processor may be.  There is no reason for this, it just is. */
/* Update: there is a reason to be little endian: the trim() and */
/* shortmultiply() would improve. */

/* All words are unsigned, so negative numbers are stored as positive */
/* numbers, and the first word keeps a sign bit. */

/* Functions set the overflow bit if the result does not fit in 32766 */
/* words (including the initial size word).  If the overflow bit is */
/* set the other fields change their meaning.  The sign bit */
/* indicates positive overflow or negative underflow.  The integer */
/* value is unusable, and is therefore reduced to the minimum of 1 */
/* word.  A design in which the value might represent positive or */
/* negative infinity (as opposed to mere overflow/underflow) is under */
/* consideration. */

/* Use biggishint at your risk and without warranty.  Give due credit */
/* if you do.  Written by Martin Berends. */

/* TODO: negative numbers (sign) */
/* TODO: overflow detection */
/* TODO: change from big endian to little endian */

#include <assert.h>  /* assert */
#include <ctype.h>   /* tolower */
#include <limits.h>  /* USHRT_MAX */
#include <stdlib.h>  /* calloc malloc realloc free */
#include <string.h>  /* strlen strncmp */
#include "biggishint.h"  /* (all externally callable functions) */

#if USHRT_MAX != 65535
#error In this C compiler a short int is not a 16 bit number.
#endif


/* Internal functions are declared here, their definitions are lower */
/* down. */
unsigned short * biggishint_internal_addsubtract(unsigned short * bi1, unsigned short * bi2, int flipsign2);
int              biggishint_internal_bitsize(unsigned long);
unsigned short * biggishint_internal_clone(unsigned short * bi1);
int              biggishint_internal_comparemagnitude(unsigned short * bi1, unsigned short * bi2);
unsigned short * biggishint_internal_shiftleft(unsigned short * bi1, unsigned int bitcount);
unsigned short * biggishint_internal_shiftright(unsigned short * bi1, unsigned int bitcount);
void             biggishint_internal_shortdivide(unsigned short * bi1, unsigned short * i2);
unsigned short * biggishint_internal_shortmultiply(unsigned short * bi1, unsigned short i2);
unsigned short * biggishint_internal_trim(unsigned short * bi1);


/* --------------------------- Functions ---------------------------- */


/* biggishintAdd */
unsigned short *
biggishintAdd(unsigned short * bi1, unsigned short * bi2)
{
    return biggishint_internal_addsubtract(bi1, bi2, 0);
}


/* biggishintDivide */
unsigned short *
biggishintDivide(unsigned short * bi1, unsigned short * bi2)
{
    /* Before starting on the main long division, which is slow, try */
    /* to identify divisors that offer an opportunity for a shortcut, */
    /* for example shifting right for divisors that are multiples of */
    /* powers of two, and short division for divisors that fit into */
    /* a small int. */
    unsigned short   bi1size, bi2size;
    unsigned short * quotient;
    bi2size = (* bi2 & 0xfffc) >> 1;
    quotient = biggishint_internal_clone(bi1);
    if (bi2size == 2) {

        unsigned short divisor = bi2[1];
        biggishint_internal_shortdivide(quotient, & divisor);
    }
    else {
        unsigned short   remaindersize;
        unsigned short * remainder;
        bi1size = * bi1 >> 1;
        remaindersize = bi1size;
        remainder = biggishint_internal_clone(bi1);
        
    /* TODO
        unsigned short biggishint1size, biggishint2size, quotientsize, remaindersize;
        unsigned short * p1, * p2, * pquotient;
        long i1, i2;
        unsigned long n1, n2, subtotal, carry;

        resultsize = biggishint1size + biggishint2size - 1;
    */
    }
    quotient = biggishint_internal_trim(quotient);
    assert( quotient != NULL );
    return quotient;
}


/* biggishintFromDecimalString */
/* Note: this algorithm is unacceptably inefficient and should be */
/* rewritten, because the two other biggishint functions it calls */
/* cause two malloc() calls per decimal digit. */
unsigned short *
biggishintFromDecimalString(char * str)
{
    char * ps, c;
    unsigned short * bi1, * bi2;
    unsigned short digitvalue[2] = {4,0};
    ps = str;
    /* Create the initial biggishint result with a value of 0 */
    bi1 = (unsigned short *) calloc(2,2);
    * bi1 = 4;
    /* take one digit at a time, convert to binary, accumulate values */
    while ( isdigit(c = * ps++) ) {
        bi2 = biggishint_internal_shortmultiply(bi1, 10);
        free(bi1);
        bi1 = bi2;
        digitvalue[1] = c - '0';
        bi2 = biggishintAdd(bi1, digitvalue);
        free(bi1);
        bi1 = bi2;
    }
    return bi1;
}


/* biggishintFromHexadecimalString */
unsigned short *
biggishintFromHexadecimalString(char * str)
{
    int hexdigitcount, biggishintwordcount, i, nybble;
    unsigned short biggishintarraysize, * biggishint, * shortPointer, value;
    char character, * strPointer;
    
    strPointer = str;
    if (strncmp(str, "0x", 2) == 0) /* skip the '0x' prefix if it exists */
        strPointer += 2;
    hexdigitcount = strlen(strPointer);
    biggishintwordcount = (((hexdigitcount+3)>>3)<<1)+1; /* 1-4=>1, 5-12=>3 etc */
    biggishintarraysize = biggishintwordcount + 1;
    biggishint = (unsigned short *) calloc(biggishintarraysize, sizeof(unsigned short));
    assert( biggishint != NULL );
    shortPointer = biggishint;
    * shortPointer++ = biggishintarraysize << 1;
    /* leave one word blank for 5-8 13-16 21-24 digit strings */
    shortPointer += ((hexdigitcount-1) & 0x4) >> 2;
    value = 0;
    for (i=hexdigitcount-1; i>=0; --i) { 
        character = tolower(* strPointer++);
        nybble = character - '0' - (character>='a' ? 'a'-'9'-1 : 0);
        value = (value<<4) + nybble;
        if ((i%4) == 0) {
            * shortPointer++ = value;
            value = 0;
        }
    }
    return biggishint;
}


/* biggishintFromLong */
unsigned short *
biggishintFromLong(long l)
{
    unsigned short * bi1, negative_bit=0;
    if (l<0) {
        negative_bit = 1;
        l = -l;
    }
    if (l <= USHRT_MAX) {
        bi1 = (unsigned short *) calloc(2,sizeof(short));
        * bi1 = 4 | negative_bit;
        bi1[1] = (unsigned short) l;
    }
    else {
        bi1 = (unsigned short *) calloc(4,sizeof(short));
        * bi1 = 8 | negative_bit;
        bi1[3] = (unsigned short) l;
        bi1[2] = l >> 16;
    }
    return bi1;
}


/* biggishintMultiply */
unsigned short *
biggishintMultiply(unsigned short * bi1, unsigned short * bi2)
{
    unsigned short bi1size, bi2size, res1size, res2size, sign1, sign2, sign;
    unsigned short * p1, * p2, * presult;
    unsigned short * result;
    long i1, i2;
    unsigned long resultsize, n1, n2, subtotal, carry;

    /* Before starting on the main long multiplication, which is */
    /* slow, try to identify multipliers that offer an opportunity */
    /* for a shortcut, for example shifting left for multipliers that */
    /* are multiples of powers of two, and short multiplication */
    /* division for multipliers that fit into a small int. */
    bi1size = (* bi1 & 0xfffc) >> 1;
    bi2size = (* bi2 & 0xfffc) >> 1;
    if (bi1size == 2)
        return biggishint_internal_shortmultiply(bi2, bi1[1]);
    if (bi2size == 2)
        return biggishint_internal_shortmultiply(bi1, bi2[1]);
    /* Create a result array that is large enough for any possible */
    /* sum */
    /* First calculate the smallest size according to the contents of */
    /* bi1 and bi2, regardless of the need to round up to an even number. */ 
    res1size = bi1size + (bi1[1] ? 0 : -1); /* the first word may be 0 */
    res2size = bi2size + (bi2[1] ? 0 : -1);
    /* Then add them together and round to an even number */
    resultsize  = (res1size + res2size + 1) & 0xfffe;
/*
#include <stdio.h>
    fprintf(stderr,"resultsize=%d\n",
        resultsize);
*/
    result = (unsigned short *) calloc(resultsize, sizeof(short));
    sign1 = * bi1 & 1;
    sign2 = * bi2 & 1;
    sign = sign1 ^ sign2;
    * result = (resultsize << 1) | sign;
    presult = result + resultsize;
    p1 = bi1 + bi1size;
    for (i1=1; i1<bi1size; ++i1) {
        n1 = * --p1;
        presult = result + resultsize - i1;
        p2 = bi2 + bi2size;
        carry = 0;
        for (i2=1; i2<bi2size; ++i2) {
            n2 = * --p2;
            subtotal = (* presult) + n1 * n2 + carry;
            carry = subtotal >> 16;
            * presult-- = subtotal & 0xffff;
        }
        while (carry) {
            * presult-- = carry;
            carry >>= 16;
        }
    }
    result = biggishint_internal_trim(result);
    assert( result != NULL );
    return result;
}


/* biggishintShiftLeft */
unsigned short *
biggishintShiftLeft(unsigned short * bi1, unsigned short * bi2)
{
    return biggishint_internal_shiftleft(bi1, bi2[1]);
}


unsigned short *
biggishintShiftRight(unsigned short * bi1, unsigned short * bi2)
{
    return NULL;
}


/* biggishintSubtract */
unsigned short *
biggishintSubtract(unsigned short * bi1, unsigned short * bi2)
{
    return biggishint_internal_addsubtract(bi1, bi2, 1);
}


/* biggishintToDecimalString */
char *
biggishintToDecimalString(unsigned short * bi1)
{
    /* The number of decimal digits that will be created is difficult */
    /* (or slow) to calculate in advance.  This routine initially */
    /* over-allocates memory, and then sizes it correctly at the end. */
    unsigned short bi1size, * bi2, digit, sign1;
    int strsize, leadingzeroes;
    char * result, * pdigits, * p1;
    /* Calculate the very maximum number of characters that the */
    /* resulting string can occupy, including a terminating '\0'. */
    /* Each word is '65535' at most, then '\0' */
    bi2 = biggishint_internal_clone(bi1);
    bi1size = (* bi1 & 0xfffc) >> 1;
    sign1 = * bi1 & 1;
    strsize = (bi1size-1) * 5 + sign1 + 1;
    result = (char *) malloc(strsize);
    assert( result != NULL );
    pdigits = result;
    if (sign1) * pdigits++ = '-';
    p1 = result + strsize;
    (* --p1) = '\0';
    do {
        digit = 10;
        biggishint_internal_shortdivide(bi2, &digit);
        (* --p1) = '0' + digit;
    } while ( p1 > pdigits ); /* TODO: find other ways to finish early */
    /* Count how many '0' characters there are at the beginning of */
    /* the string, and then move the non '0' characters. */
    leadingzeroes = strspn(pdigits, "0");
    if (leadingzeroes == strsize - sign1 - 1)
        --leadingzeroes;
    if (leadingzeroes) {
        memmove(pdigits, pdigits+leadingzeroes, strsize-sign1-leadingzeroes); /* (Big Endian)-- ;) */
        result = realloc(result, strsize-leadingzeroes);
    }
    return result;
}


/* biggishintToHexadecimalString */
char *
biggishintToHexadecimalString(unsigned short * bi1)
{
    int bi1size, hexstringsize, i, j, value, nybble, emitzero, sign;
    char * hexString, * hexPointer;
    bi1size = (* bi1 & 0xfffc) >> 1;
    sign = * bi1 & 1;
    /* Calculate how many characters the hex string needs, including */
    /* the "0x" at the beginning and a '\0' at the end */
    hexstringsize = ((biggishint_internal_bitsize(bi1[1])+3)>>2)
        + sign + bi1size * 4 - 5; /* '0x' + sign + digits + '\0' */
    hexString = (char *) malloc(hexstringsize);
    assert( hexString != NULL );
    hexPointer = hexString;
    if (sign) * hexPointer++ = '-';
    * hexPointer++ = '0'; * hexPointer++ = 'x';
    emitzero = 0;  /* do not emit leading zeroes */
    for (i=1; i<bi1size; ++i) {
        value = bi1[i];
        for (j=3; j>=0; --j) {
            nybble = (value >> (j*4)) & 0xf;
            if (nybble || emitzero) {
                * hexPointer++ = '0' + nybble + ((nybble>9) ? 'a'-'9'-1 : 0);
                emitzero = 1;
            }
        }
    }
    if (! emitzero)
        * hexPointer++ = '0';
    * hexPointer = '\0';
    return hexString;
}


/* ----------------------- Internal functions ----------------------- */
/* Except for biggishint_internal_trim, the internal functions do not */
/* trim their results, because it costs time, may be redundant, and */
/* increases heap churn. */


/* biggishint_internal_addsubtract */
unsigned short * biggishint_internal_addsubtract(unsigned short * bi1, unsigned short * bi2, int flipsign2)
{
    unsigned short bi1size, bi2size, res1size, res2size, resultsize;
    unsigned short * result1, * result2, * larger, * smaller, * p1, * p2;
    unsigned int sign1, sign2, sign, carry, i1, i2;
    signed long partialresult;
    sign1 = * bi1 & 1;
    sign2 = * bi2 & 1;
    if (sign1 ^ sign2 ^ flipsign2) {  /* different signs, do a subtract */
        /* the larger number determines the size and sign of the result */
        if (biggishint_internal_comparemagnitude(bi1,bi2) >= 0) {
            larger  = bi1; smaller = bi2; sign = sign1;
        }
        else {
            smaller = bi1; larger  = bi2; sign = sign2 ^ flipsign2;
        }
        resultsize = (* larger & 0xfffc) >> 1;
        result1 = (unsigned short *) calloc(resultsize, sizeof(short));
        result2 = result1 + resultsize;
        p1 = larger  + ((* larger  & 0xfffc) >> 1);
        p2 = smaller + ((* smaller & 0xfffc) >> 1);
        carry = 0;
        partialresult = 0;
        while (--p1 > larger) {
            i1 = * p1;
            i2 = (--p2 > smaller) ? * p2 : 0;
            partialresult += i1 - i2;
            * --result2 = (partialresult >=0)
                          ? (unsigned short) partialresult
                          : (unsigned short) (partialresult + 65536);
            partialresult = (partialresult & 0xffff0000) ? -1 : 0;
        }
    }  /* subtract */
    else {  /* same signs, do an add */
        bi1size = (* bi1 & 0xfffc) >> 1;
        bi2size = (* bi2 & 0xfffc) >> 1;
        res1size = bi1size + (bi1[1] ? 1 : 0); /* the first word may be 0 */
        res2size = bi2size + (bi2[1] ? 1 : 0);
        resultsize  = ((res1size > res2size ? res1size : res2size) + 1) & 0xfffe;
        sign = sign1;
        result1 = (unsigned short *) calloc(resultsize, sizeof(short));
        assert( result1 != NULL );
        /* Initialize pointers to the augend (bi1), addend (bi2) and partialresult */
        * result1 = resultsize << 1;
        p1      = bi1 + bi1size - 1;
        p2      = bi2 + bi2size - 1;
        result2 = result1 + resultsize - 1;
        carry = 0;
        /* Iteratively add words from least significant to most */
        while (result2 > result1) {
            i1 = i2 = 0;
            if (p1 > bi1)
                i1 = * p1--;
            if (p2 > bi2)
                i2 = * p2--;
            partialresult = i1 + i2 + carry;
            carry = 0;
            if (partialresult > USHRT_MAX) {
                carry = 1;
                partialresult -= (USHRT_MAX + 1);
            }
            * result2-- = (unsigned short) partialresult;
        }  /* while */
    }  /* add */
/*
#include <stdio.h>
    fprintf(stderr,"sign %d\n", sign);
*/
    * result1 = (resultsize << 1) | sign;
    result1 = biggishint_internal_trim(result1);
    assert( result1 != NULL );
    return result1;
}

/* biggishint_internal_bitsize */
/* Count how many bits a number uses (0-64), returns 1 + position of first 1 bit */
int
biggishint_internal_bitsize(unsigned long n)
{
    int bitsize = 0;
    for ( ; n; n >>= 1)
        ++bitsize;
    return bitsize;
}


/* biggishint_internal_clone */
unsigned short *
biggishint_internal_clone(unsigned short * bi1)
{
    unsigned short clonebytes, * clone;
    clonebytes = * bi1 & 0xfffffffe;
    clone = (unsigned short *) malloc(clonebytes);
    assert( clone != NULL );
    memcpy(clone, bi1, clonebytes);
    return clone;
}


/* biggishint_internal_comparemagnitude */
/* returns -1 if bi1<bi2, 0 if bi1==bi2, +1 if bi1>bi2 */
int biggishint_internal_comparemagnitude(unsigned short * bi1, unsigned short * bi2)
{
    unsigned short * pi1data, * pi1, * pi2data, * pi2;
    unsigned short i1, i2, bi1size, bi2size, loopcount;
    int result=0;
    /* This function could often be quicker by comparing the sizes of */
    /* the two numbers, but that implies trusting the rest of the */
    /* code to always trim leading zero words where possible.  The */
    /* test suite currently lacks the coverage required to enable */
    /* that trust. */
    bi1size = (* bi1 & 0xfffc) >> 1;
    bi2size = (* bi2 & 0xfffc) >> 1;
    /* the max number of comparisons is max(bi1size,bi2size)-1 */
    loopcount = ((bi1size>bi2size) ? bi1size : bi2size) - 1;
    pi1data = bi1 + 1;
    pi2data = bi2 + 1;
    pi1     = bi1 + bi1size - loopcount;
    pi2     = bi2 + bi2size - loopcount;
    while (result==0 && loopcount--) {
        /* substitute leading zeroes for whichever number is shorter */
        i1 = (pi1<pi1data) ? 0 : * pi1;  ++pi1;
        i2 = (pi2<pi2data) ? 0 : * pi2;  ++pi2;
        /* compare the two words from each biggishint */
        result = (i1<i2) ? -1 : (i1>i2) ? 1 : 0;
    }
    return result;
}

/* biggishint_internal_shiftleft */
unsigned short *
biggishint_internal_shiftleft(unsigned short * bi1, unsigned int bitcount)
{
    unsigned short bi1size, * result, * p1, * p2, carry;
    unsigned int inputbitcount, resultbitcount, resultsize, inputloop;
    unsigned int shiftleft, shiftright, inputword, resultword;
    bi1size = (* bi1 & 0xfffc) >> 1;
    /* Calculate the number of data bits needed for the result */
    inputbitcount = biggishint_internal_bitsize(bi1[1]) + ((bi1size - 2) << 4);
    resultbitcount = inputbitcount + bitcount;
    assert( resultbitcount < 524272);
    /* Calculate the total number of words to allocate for the result */
    resultsize = 1 + ((resultbitcount + 15) >> 4);
    result = (unsigned short *) calloc(resultsize, sizeof(short));
    * result = resultsize << 1;
    /* prepare initial values for the loop below */
    shiftleft  = bitcount & 0xf;
    shiftright = 16 - shiftleft;
    p1 = bi1 + 1;
    p2 = result + 1;
    inputword = * p1++;
    inputloop = bi1size;
    carry = inputword << shiftleft;
    /* Check whether part of the first word of the input needs to */
    /* carry over to the second word of the result */
    if ( ((inputbitcount-1) & 0xf) > ((resultbitcount-1) & 0xf) ) {
        /* Yes, so here store the bits that will not be carried */
        resultword = inputword >> shiftright;
        * p2++ = resultword;
        --inputloop;
    }
    while (--inputloop) {
        inputword = * p1++;
        resultword = carry | (inputword >> shiftright);
        * p2++ = resultword;
        carry = inputword << shiftleft;
    }
    * p2++ = carry;
    return result;
}


/* TODO: biggishint_internal_shiftright */
unsigned short *
biggishint_internal_shiftright(unsigned short * bi1, unsigned int bitcount)
{
    unsigned short bi1size, * result;
    bi1size = 2;
    result = (unsigned short *) malloc(bi1size);
    return result;
}


/* biggishint_internal_shortdivide */
/* Short division only (divisor <= 0xffff). */
/* Returns quotient in (* bi1), remainder in (* i2) */
void
biggishint_internal_shortdivide(unsigned short * bi1, unsigned short * i2)
{
    unsigned short bi1size, * pi1, * pi2, divisor, remainder, hi, lo;
    unsigned long partialdividend, partialquotient;
    bi1size   = (* bi1 & 0xfffc) >> 1;
    divisor   = * i2;
    remainder = 0;
    pi1       = bi1 + 1;
    pi2       = bi1 + bi1size;
    lo        = 0;
    while ( pi1 < pi2 ) {
        hi = lo;
        lo = * pi1;
        partialdividend = ((unsigned long)hi << 16) | lo;
        partialquotient = partialdividend / divisor;
        remainder       = partialdividend % divisor;
        hi = partialquotient & 0xffff;
        lo = remainder;
        * pi1++ = hi;
    }
    * i2 = remainder;
}


/* biggishint_internal_shortmultiply */
unsigned short *
biggishint_internal_shortmultiply(unsigned short * bi1, unsigned short i2)
{
    unsigned short bi1size, productsize, * product, * pi, * pp;
    unsigned long partialproduct, multiplier;
    bi1size   = (* bi1 & 0xfffc) >> 1;
    multiplier = i2;
    productsize = bi1size + 4;
    product = (unsigned short *) calloc(productsize, sizeof(short));
    * product = productsize << 1;
    pi = bi1     + bi1size     - 1;
    pp = product + productsize - 1;
    partialproduct = 0;
    do {
        partialproduct += (* pi--) * multiplier;
        (* pp--) = (unsigned short) partialproduct;
        partialproduct >>= 16;
    } while ( pi > bi1 );
    (* pp--) = (unsigned short) partialproduct;
    product = biggishint_internal_trim(product);
    return product;
}


/* biggishint_internal_trim */
/* If possible, remove leading zeroes from the front of the biggishint */
/* Note: it reallocates the data, so it may be at a new address. */
unsigned short *
biggishint_internal_trim(unsigned short * bi1)
{
    /* For example, change this: */
    /* +------+------+------+------+------+------+ */
    /* | 000c | 0000 | 0000 | 0000 | 1234 | cdef | */
    /* +------+------+------+------+------+------+ */
    /* to this: */
    /* +------+------+------+------+ */
    /* | 0008 | 0000 | 1234 | cdef | */
    /* +------+------+------+------+ */
    unsigned int bi1size, newsize, sign;
    unsigned short * pLeft, * pSearch, * pRight, * pAfterZeroes;
    size_t bytecount;

    /* Count the number of contiguous leading zero words */
    bi1size = (* bi1 & 0xfffc) >> 1;
    sign         = (* bi1) &  1;
    pLeft        = bi1 + 1;
    pSearch      = bi1;
    pRight       = bi1 + bi1size; /* the first address after the biggishint */
    pAfterZeroes = pRight;
    /* Try to set p3 to the address of the first non zero word */
    /* After this loop completes, pAfterZeroes either points to the */
    /* first nonzero word, or to the first address after the biggishint. */
    while (++pSearch < pAfterZeroes) /* note pAfterZeroes moves! */
        if ( * pSearch )
            pAfterZeroes = pSearch;
    /* If there are leading words filled with zeroes, move the non */
    /* zero words to the left to overwrite them */
    if (pAfterZeroes > pLeft && pAfterZeroes < pRight) {
        newsize = (pRight - pAfterZeroes + 2) & 0xfffe; /* always even */
        if (newsize < bi1size) {
            * bi1 = (newsize << 1) | sign;
            bytecount = (pRight - pAfterZeroes) << 1;
            memmove(pLeft, pAfterZeroes, bytecount); /* (Big Endian)-- ;) */
            bytecount += 2;
            /* Trim the size of the memory allocation */
            bi1 = realloc(bi1, bytecount);
        }
    }
    return bi1;
}


/* end of biggishint.c */

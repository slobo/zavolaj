/* biggishint.h */

unsigned short * biggishintAdd                   (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintBitwiseAnd            (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintBitwiseNot            (unsigned short * biggishint);
unsigned short * biggishintBitwiseOr             (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintBitwiseXor            (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintCompare               (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintDecrement             (unsigned short * biggishint);
unsigned short * biggishintDivide                (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintFromDecimalString     (char * str);
unsigned short * biggishintFromHexadecimalString (char * str);
unsigned short * biggishintIncrement             (unsigned short * biggishint);
unsigned short * biggishintLogicalAnd            (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintLogicalNot            (unsigned short * biggishint);
unsigned short * biggishintLogicalOr             (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintLogicalXor            (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintModulo                (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintMultiply              (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintPower                 (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintShiftLeft             (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintShiftRight            (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintSubtract              (unsigned short * biggishint1, unsigned short * biggishint2);
char           * biggishintToHexadecimalString   (unsigned short * biggishint);
char           * biggishintToDecimalString       (unsigned short * biggishint);
/*                                               ^ no, you can't do this in Perl 6! */
/* end of biggishint.h */

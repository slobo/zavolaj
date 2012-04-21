#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

typedef struct {
    long intval;
    double numval;
    long *arr;
} MyStruct;

typedef struct { long   first, second; } IntStruct;
typedef struct { double first, second; } NumStruct;
typedef struct {
    IntStruct *a;
    NumStruct *b;
} StructStruct;

DLLEXPORT MyStruct *ReturnAStruct()
{
    MyStruct *obj = (MyStruct *) malloc(sizeof(MyStruct));
    obj->intval = 17;
    obj->numval = 4.2;
    obj->arr = (long *) malloc(3*sizeof(long));
    obj->arr[0] = 2;
    obj->arr[1] = 3;
    obj->arr[2] = 5;

    return obj;
}

DLLEXPORT void TakeAStruct(MyStruct *obj)
{
    if(obj->intval != 42) printf("not ");
    printf("ok - C-side int value\n");
    if(obj->numval != -3.7) printf("not ");
    printf("ok - C-side num value\n");
    if(!obj->arr || obj->arr[0] != 1) printf("not ");
    printf("ok - C-side array value, element 1\n");
    if(!obj->arr || obj->arr[1] != 2) printf("not ");
    printf("ok - C-side array value, element 2\n");
}

DLLEXPORT StructStruct *ReturnAStructStruct() {
    StructStruct *ss = (StructStruct *) malloc(sizeof(StructStruct));
    ss->a = (IntStruct *) malloc(sizeof(IntStruct));
    ss->b = (NumStruct *) malloc(sizeof(NumStruct));
    ss->a->first  = 7;
    ss->a->second = 11;
    ss->b->first  = 3.7;
    ss->b->second = 0.1;

    return ss;
}

DLLEXPORT void TakeAStructStruct(StructStruct *obj) {
    if(!obj->a || obj->a->first != 13) printf("not ");
    printf("ok - int 1 in struct 1 in struct\n");
    if(!obj->a || obj->a->second != 17) printf("not ");
    printf("ok - int 2 in struct 1 in struct\n");
    if(!obj->b || obj->b->first != 0.9) printf("not ");
    printf("ok - int 1 in struct 2 in struct\n");
    if(!obj->b || obj->b->second != 3.14) printf("not ");
    printf("ok - int 2 in struct 2 in struct\n");
}
